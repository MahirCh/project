<%@ page import="java.sql.*" %>
<%
String auctionIdStr = request.getParameter("auction_id");
String bidder = (String) session.getAttribute("username");
if (bidder == null) bidder = (String) session.getAttribute("user");

if (auctionIdStr == null || auctionIdStr.trim().isEmpty() || bidder == null) {
    out.println("<h3>Missing parameters or not logged in.</h3>");
    return;
}

int aucId = Integer.parseInt(auctionIdStr);
double bidAmount;

try {
    bidAmount = Double.parseDouble(request.getParameter("bid_amount"));
} catch (Exception e) {
    out.println("<h3>Invalid bid amount.</h3>");
    return;
}

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.jdbc.Driver");
    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/projectdb", "root", "school");

    // Load auction info
    ps = con.prepareStatement("SELECT increment, end_time, reserve_price FROM auction WHERE auction_id=?");
    ps.setInt(1, aucId);
    rs = ps.executeQuery();

    double increment = 1.0;
    Timestamp endTs = null;
    Double reservePrice = null;

    if (rs.next()) {
        increment = rs.getDouble("increment");
        endTs = rs.getTimestamp("end_time");
        reservePrice = rs.getObject("reserve_price") != null ? rs.getDouble("reserve_price") : null;
    } else {
        out.println("<h3>Auction not found.</h3>");
        return;
    }
    rs.close();
    ps.close();

    Timestamp now = new Timestamp(System.currentTimeMillis());

    // If closed, compute winner and exit
    if (now.after(endTs)) {
        out.println("<h2>Auction already closed. No more bids allowed.</h2>");

        ps = con.prepareStatement(
            "SELECT username, bid_amount FROM bid WHERE auc_id=? ORDER BY bid_amount DESC, bid_time ASC LIMIT 1"
        );
        ps.setInt(1, aucId);
        rs = ps.executeQuery();

        String topUser = null;
        double topBid = 0.0;

        if (rs.next()) {
            topUser = rs.getString("username");
            topBid = rs.getDouble("bid_amount");
        }
        rs.close();
        ps.close();

        if (topUser != null) {
            if (reservePrice != null && topBid < reservePrice) {
                ps = con.prepareStatement("UPDATE auction SET winner_id=NULL, winning_bid=NULL WHERE auction_id=?");
                ps.setInt(1, aucId);
                ps.executeUpdate();
                ps.close();

                out.println("<p>Reserve not met. No winner.</p>");
            } else {
                ps = con.prepareStatement("UPDATE auction SET winner_id=?, winning_bid=? WHERE auction_id=?");
                ps.setString(1, topUser);
                ps.setDouble(2, topBid);
                ps.setInt(3, aucId);
                ps.executeUpdate();
                ps.close();

                ps = con.prepareStatement("INSERT INTO alert (username, auc_id, message) VALUES (?, ?, ?)");
                ps.setString(1, topUser);
                ps.setInt(2, aucId);
                ps.setString(3, "You won auction #" + aucId + " with bid $" + topBid);
                ps.executeUpdate();
                ps.close();

                out.println("<p>Winner was already determined: " + topUser + "</p>");
            }
        }

        out.println("<p><a href='success.jsp'>Back home</a></p>");
        return;
    }

    // Auction still open: place bid
    ps = con.prepareStatement("INSERT INTO bid (auc_id, username, bid_amount, bid_time) VALUES (?, ?, ?, NOW())");
    ps.setInt(1, aucId);
    ps.setString(2, bidder);
    ps.setDouble(3, bidAmount);
    ps.executeUpdate();
    ps.close();

    // Auto bid loop
    boolean changed = true;
    while (changed) {
        changed = false;

        ps = con.prepareStatement(
            "SELECT username, bid_amount FROM bid WHERE auc_id=? ORDER BY bid_amount DESC, bid_time ASC LIMIT 1"
        );
        ps.setInt(1, aucId);
        rs = ps.executeQuery();

        String topUser = null;
        double topBid = 0.0;

        if (rs.next()) {
            topUser = rs.getString("username");
            topBid = rs.getDouble("bid_amount");
        }
        rs.close();
        ps.close();

        ps = con.prepareStatement(
            "SELECT bidder_username, max_bid FROM auto_bid WHERE auction_id=? AND bidder_username<>? ORDER BY max_bid DESC"
        );
        ps.setInt(1, aucId);
        ps.setString(2, topUser == null ? "" : topUser);
        rs = ps.executeQuery();

        boolean placed = false;
        while (rs.next()) {
            String challenger = rs.getString("bidder_username");
            double maxBid = rs.getDouble("max_bid");

            if (maxBid >= topBid + increment) {
                double newBid = Math.min(maxBid, topBid + increment);

                PreparedStatement ps2 = con.prepareStatement(
                    "INSERT INTO bid (auc_id, username, bid_amount, bid_time) VALUES (?, ?, ?, NOW())"
                );
                ps2.setInt(1, aucId);
                ps2.setString(2, challenger);
                ps2.setDouble(3, newBid);
                ps2.executeUpdate();
                ps2.close();

                placed = true;
                break;
            }
        }
        rs.close();
        ps.close();

        if (placed) changed = true;
    }

    // Final highest bid
    ps = con.prepareStatement(
        "SELECT username, bid_amount FROM bid WHERE auc_id=? ORDER BY bid_amount DESC, bid_time ASC LIMIT 1"
    );
    ps.setInt(1, aucId);
    rs = ps.executeQuery();

    String finalUser = null;
    double finalBid = 0.0;

    if (rs.next()) {
        finalUser = rs.getString("username");
        finalBid = rs.getDouble("bid_amount");
    }
    rs.close();
    ps.close();

    out.println("<h2>Bid placed successfully!</h2>");
    out.println("<p>Current highest bidder: " + finalUser + "</p>");
    out.println("<p>Current bid: $" + finalBid + "</p>");
    out.println("<p><a href='success.jsp'>Back home</a></p>");

} catch (Exception e) {
    out.println("<pre>");
    java.io.StringWriter sw = new java.io.StringWriter();
    java.io.PrintWriter pw = new java.io.PrintWriter(sw);
    e.printStackTrace(pw);
    out.println(sw.toString());
    out.println("</pre>");
} finally {
    try { if (rs != null) rs.close(); } catch (Exception ex) {}
    try { if (ps != null) ps.close(); } catch (Exception ex) {}
    try { if (con != null) con.close(); } catch (Exception ex) {}
}
%>
