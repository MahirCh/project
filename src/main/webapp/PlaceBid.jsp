<%@ page import="java.sql.*" %>
<%@ page import="java.text.*" %>
<%
request.setCharacterEncoding("UTF-8");

String aucIdStr = request.getParameter("auction_id");
String bidder = (String) session.getAttribute("user"); // must match how you store session username
String bidAmtStr = request.getParameter("bid_amount");
String upperStr = request.getParameter("upper_limit"); // match your form name

if (aucIdStr == null || bidAmtStr == null || bidder == null) {
    out.println("<h3>Missing parameter(s). auction_id, bid_amount and logged-in user are required.</h3>");
    return;
}

int aucId = 0;
double bidAmount = 0.0;
Double upperLimit = null;
try {
    aucId = Integer.parseInt(aucIdStr);
    bidAmount = Double.parseDouble(bidAmtStr);
    if (upperStr != null && !upperStr.trim().isEmpty()) {
        upperLimit = Double.parseDouble(upperStr);
    }
} catch(Exception ex) {
    out.println("<h3>Invalid numeric parameter: " + ex.getMessage() + "</h3>");
    return;
}

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.jdbc.Driver");
    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/projectdb", "root", "school");
    con.setAutoCommit(false); // transactional

    // --- sanity check: ensure bidder exists in eu_account (or buyer) ---
    ps = con.prepareStatement("SELECT username FROM eu_account WHERE username=?");
    ps.setString(1, bidder);
    rs = ps.executeQuery();
    if (!rs.next()) {
        rs.close(); ps.close();
        con.rollback();
        out.println("<h3>Bidder account not found: " + bidder + "</h3>");
        return;
    }
    rs.close(); ps.close();

    // --- 1) Insert manual bid ---
    ps = con.prepareStatement(
        "INSERT INTO bid (auc_id, username, bid_amount, bid_time) VALUES (?, ?, ?, NOW())"
    );
    ps.setInt(1, aucId);
    ps.setString(2, bidder);
    ps.setDouble(3, bidAmount);
    ps.executeUpdate();
    ps.close();

    // --- 2) Upsert auto_bid limit if provided (delete then insert) ---
    if (upperLimit != null && upperLimit > bidAmount) {
        ps = con.prepareStatement("DELETE FROM auto_bid WHERE auction_id=? AND bidder_username=?");
        ps.setInt(1, aucId);
        ps.setString(2, bidder);
        ps.executeUpdate();
        ps.close();

        ps = con.prepareStatement("INSERT INTO auto_bid (auction_id, bidder_username, max_bid) VALUES (?, ?, ?)");
        ps.setInt(1, aucId);
        ps.setString(2, bidder);
        ps.setDouble(3, upperLimit);
        ps.executeUpdate();
        ps.close();
    }

    // --- 3) Get increment from Auction with FOR UPDATE to lock the auction row ---
    ps = con.prepareStatement("SELECT increment FROM auction WHERE auction_id = ? FOR UPDATE");
    ps.setInt(1, aucId);
    rs = ps.executeQuery();
    double increment = 1.0;
    if (rs.next()) increment = rs.getDouble("increment");
    rs.close(); ps.close();

    // --- 4) Auto-bid competition loop (repeat until no change) ---
    boolean changed = true;
    String currentTopUser = null;
    double currentTopBid = 0.0;

    while (changed) {
        changed = false;

        // a) fetch current highest bid for this auction
        ps = con.prepareStatement(
            "SELECT username, bid_amount FROM bid WHERE auc_id = ? ORDER BY bid_amount DESC, bid_time ASC LIMIT 1 FOR UPDATE"
        );
        ps.setInt(1, aucId);
        rs = ps.executeQuery();
        if (rs.next()) {
            currentTopUser = rs.getString("username");
            currentTopBid = rs.getDouble("bid_amount");
        } else {
            // Shouldn't happen because we inserted the manual bid; but guard
            currentTopUser = bidder;
            currentTopBid = bidAmount;
        }
        rs.close(); ps.close();

        // b) scan all auto-bidders except current top user, sorted by max_bid DESC
        ps = con.prepareStatement(
            "SELECT bidder_username, max_bid FROM auto_bid WHERE auction_id = ? AND bidder_username <> ? ORDER BY max_bid DESC"
        );
        ps.setInt(1, aucId);
        ps.setString(2, currentTopUser == null ? "" : currentTopUser);
        rs = ps.executeQuery();

        while (rs.next()) {
            String challenger = rs.getString("bidder_username");
            double challengerMax = rs.getDouble("max_bid");

            // can challenger outbid current top?
            if (challengerMax >= currentTopBid + increment) {
                double newBid = Math.min(challengerMax, currentTopBid + increment);

                // insert auto-generated bid for challenger
                PreparedStatement psIns = con.prepareStatement(
                    "INSERT INTO bid (auc_id, username, bid_amount, bid_time) VALUES (?, ?, ?, NOW())"
                );
                psIns.setInt(1, aucId);
                psIns.setString(2, challenger);
                psIns.setDouble(3, newBid);
                psIns.executeUpdate();
                psIns.close();

                // mark changed so loop repeats and picks up new top
                changed = true;
                // break out of scanning challengers to let loop refresh the highest bid
                // (this mimics real-time iterative bidding)
                break;
            }
        }
        rs.close(); ps.close();
    }

    // commit all bid changes
    con.commit();

    // fetch final highest to display
    ps = con.prepareStatement("SELECT username, bid_amount FROM bid WHERE auc_id = ? ORDER BY bid_amount DESC, bid_time ASC LIMIT 1");
    ps.setInt(1, aucId);
    rs = ps.executeQuery();
    String finalUser = bidder;
    double finalAmount = bidAmount;
    if (rs.next()) {
        finalUser = rs.getString("username");
        finalAmount = rs.getDouble("bid_amount");
    }
    rs.close(); ps.close();

    out.println("<h2>Bid Placed!</h2>");
    out.println("<p>Highest bidder now: <b>" + finalUser + "</b></p>");
    out.println("<p>Highest bid: <b>$" + new java.text.DecimalFormat("#0.00").format(finalAmount) + "</b></p>");
    out.println("<p><a href='success.jsp'>Return</a></p>");

} catch (Exception e) {
    try { if (con != null) con.rollback(); } catch(Exception ex) {}
    out.println("<h3>Error: " + e.getMessage() + "</h3>");
    java.io.StringWriter sw = new java.io.StringWriter();
    e.printStackTrace(new java.io.PrintWriter(sw));
    out.println("<pre>" + sw.toString() + "</pre>");
} finally {
    try { if (rs != null) rs.close(); } catch(Exception ex) {}
    try { if (ps != null) ps.close(); } catch(Exception ex) {}
    try { if (con != null) con.close(); } catch(Exception ex) {}
}
%>
