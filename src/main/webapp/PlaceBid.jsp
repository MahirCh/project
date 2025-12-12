<%@ page import="java.sql.*" %>
<%@ page import="java.time.*" %>
<%@ page import="java.time.format.*" %>
<%
/*
PlaceBid.jsp

Expected POST form fields:
 - auction_id
 - bid_amount
 - upper_limit   (optional)  <-- buyer's max auto-bid

Session:
 - username or user (the logged-in buyer username)

Assumptions about DB schema (adjust if needed):
 - auction(auction_id INT PK, start_price DOUBLE, increment DOUBLE, reserve_price DOUBLE, start_time DATETIME, end_time DATETIME, winner_id VARCHAR(...), winning_bid DOUBLE, seller_username ...)
 - bid(bid_id AUTO_INC PK, auc_id INT, username VARCHAR(...), bid_amount DOUBLE, bid_time TIMESTAMP)
 - auto_bid(auto_bid_id AUTO_INC PK, auction_id INT, bidder_username VARCHAR(...), max_bid DECIMAL)
 - alert(alert_id AUTO_INC PK, username VARCHAR(...), auc_id INT, message TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, is_read BOOLEAN DEFAULT FALSE)
*/

String auctionIdStr = request.getParameter("auction_id");
String bidder = (String) session.getAttribute("username");
if (bidder == null) bidder = (String) session.getAttribute("user");

if (auctionIdStr == null || auctionIdStr.trim().isEmpty() || bidder == null) {
    out.println("<h3>Missing parameters or not logged in.</h3>");
    return;
}

int aucId = Integer.parseInt(auctionIdStr);
double bidAmount = 0.0;
try {
    bidAmount = Double.parseDouble(request.getParameter("bid_amount"));
} catch(Exception ex) {
    out.println("<h3>Invalid bid amount.</h3>");
    return;
}

String maxStr = request.getParameter("upper_limit");
Double maxBid = null;
if (maxStr != null && !maxStr.trim().isEmpty()) {
    try { maxBid = Double.parseDouble(maxStr); } catch(Exception ex) { maxBid = null; }
}

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.jdbc.Driver");
    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/projectdb","root","school");

    // Insert the immediate bid
    ps = con.prepareStatement(
        "INSERT INTO bid (auc_id, username, bid_amount, bid_time) VALUES (?, ?, ?, NOW())"
    );
    ps.setInt(1, aucId);
    ps.setString(2, bidder);
    ps.setDouble(3, bidAmount);
    ps.executeUpdate();
    ps.close();

    // Save or update auto bid record
    if (maxBid != null && maxBid > bidAmount) {
        ps = con.prepareStatement("DELETE FROM auto_bid WHERE auction_id=? AND bidder_username=?");
        ps.setInt(1, aucId);
        ps.setString(2, bidder);
        ps.executeUpdate();
        ps.close();

        ps = con.prepareStatement(
            "INSERT INTO auto_bid (auction_id, bidder_username, max_bid) VALUES (?, ?, ?)"
        );
        ps.setInt(1, aucId);
        ps.setString(2, bidder);
        ps.setDouble(3, maxBid);
        ps.executeUpdate();
        ps.close();
    }

    double increment = 1.0;
    ps = con.prepareStatement("SELECT increment, end_time, reserve_price FROM auction WHERE auction_id=?");
    ps.setInt(1, aucId);
    rs = ps.executeQuery();
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

    // Auto bid competition
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

        boolean challengerPlaced = false;
        while (rs.next()) {
            String challenger = rs.getString("bidder_username");
            double challengerMax = rs.getDouble("max_bid");

            if (challengerMax >= topBid + increment) {
                double newBid = Math.min(challengerMax, topBid + increment);

                PreparedStatement ps2 = con.prepareStatement(
                    "INSERT INTO bid (auc_id, username, bid_amount, bid_time) VALUES (?, ?, ?, NOW())"
                );
                ps2.setInt(1, aucId);
                ps2.setString(2, challenger);
                ps2.setDouble(3, newBid);
                ps2.executeUpdate();
                ps2.close();

                challengerPlaced = true;
                break;
            }
        }
        rs.close();
        ps.close();

        if (challengerPlaced) changed = true;
    }

    // Fetch final highest bid
    ps = con.prepareStatement(
        "SELECT username, bid_amount FROM bid WHERE auc_id=? ORDER BY bid_amount DESC, bid_time ASC LIMIT 1"
    );
    ps.setInt(1, aucId);
    rs = ps.executeQuery();

    String finalTopUser = null;
    double finalTopBid = 0.0;
    if (rs.next()) {
        finalTopUser = rs.getString("username");
        finalTopBid = rs.getDouble("bid_amount");
    }
    rs.close();
    ps.close();

    // Auction closed check
    boolean auctionClosed = false;
    if (endTs != null) {
        Timestamp now = new Timestamp(System.currentTimeMillis());
        if (!now.before(endTs)) auctionClosed = true;
    }

    if (auctionClosed) {

        if (reservePrice != null && finalTopBid < reservePrice) {
            ps = con.prepareStatement("UPDATE auction SET winner_id = NULL, winning_bid = NULL WHERE auction_id = ?");
            ps.setInt(1, aucId);
            ps.executeUpdate();
            ps.close();

            out.println("<h2>Auction closed - no winner (reserve price not met).</h2>");
        } else {

            if (finalTopUser != null) {
                ps = con.prepareStatement("UPDATE auction SET winner_id = ?, winning_bid = ? WHERE auction_id = ?");
                ps.setString(1, finalTopUser);
                ps.setDouble(2, finalTopBid);
                ps.setInt(3, aucId);
                ps.executeUpdate();
                ps.close();

                ps = con.prepareStatement("INSERT INTO alert (username, auc_id, message) VALUES (?, ?, ?)");
                ps.setString(1, finalTopUser);
                ps.setInt(2, aucId);
                ps.setString(3, "Congratulations! You won auction #" + aucId + " with a bid of $" + finalTopBid);
                ps.executeUpdate();
                ps.close();

                out.println("<h2>Auction closed - winner: " + finalTopUser + " ($" + finalTopBid + ")</h2>");
                out.println("<p>An alert has been created for the winner.</p>");
            } else {
                out.println("<h2>Auction closed - no bids placed.</h2>");
            }
        }

    } else {
        out.println("<h2>Bid placed!</h2>");
        out.println("<p>Current highest bidder: " + (finalTopUser == null ? "none" : finalTopUser) + "</p>");
        out.println("<p>Current highest bid: $" + finalTopBid + "</p>");
    }

    out.println("<p><a href='success.jsp'>Back home</a></p>");

} catch (Exception e) {
    out.println("<h3>Error: " + e.getMessage() + "</h3>");
    java.io.StringWriter sw = new java.io.StringWriter();
    java.io.PrintWriter pw = new java.io.PrintWriter(sw);
    e.printStackTrace(pw);
    out.println("<pre>"+sw.toString()+"</pre>");
} finally {
    try { if (rs != null) rs.close(); } catch(Exception x) {}
    try { if (ps != null) ps.close(); } catch(Exception x) {}
    try { if (con != null) con.close(); } catch(Exception x) {}
}
%>
