<%@ page import="java.sql.*" %>

<%
    String bidder = (String) session.getAttribute("username");
    String artist = request.getParameter("artist");
    String album  = request.getParameter("album");
    double bidAmount = Double.parseDouble(request.getParameter("bid_amount"));
    String maxStr = request.getParameter("max_bid");

    Double maxBid = null;
    if (maxStr != null && !maxStr.trim().equals("")) {
        maxBid = Double.parseDouble(maxStr);
    }

    Connection con = null;
    PreparedStatement ps = null;

    try {
        Class.forName("com.mysql.jdbc.Driver");
        con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/projectdb", "root", "school"
        );

        // ----------------------------------------------------
        // 1. Insert the bidder's immediate bid into bid table
        // ----------------------------------------------------
        ps = con.prepareStatement(
            "INSERT INTO bid (artist, album_title, bidder_username, bid_amount, bid_time) " +
            "VALUES (?, ?, ?, ?, NOW())"
        );
        ps.setString(1, artist);
        ps.setString(2, album);
        ps.setString(3, bidder);
        ps.setDouble(4, bidAmount);
        ps.executeUpdate();
        ps.close();

        // ----------------------------------------------------
        // 2. If auto-bid upper limit was provided, store it
        // ----------------------------------------------------
        if (maxBid != null && maxBid > bidAmount) {

            // Remove old auto-bid for this user & item
            ps = con.prepareStatement(
                "DELETE FROM auto_bid WHERE artist=? AND album_title=? AND bidder_username=?"
            );
            ps.setString(1, artist);
            ps.setString(2, album);
            ps.setString(3, bidder);
            ps.executeUpdate();
            ps.close();

            // Insert new auto-bid definition
            ps = con.prepareStatement(
                "INSERT INTO auto_bid (artist, album_title, bidder_username, max_bid) " +
                "VALUES (?, ?, ?, ?)"
            );
            ps.setString(1, artist);
            ps.setString(2, album);
            ps.setString(3, bidder);
            ps.setDouble(4, maxBid);
            ps.executeUpdate();
            ps.close();
        }

        // ----------------------------------------------------
        // 3. Run auto-bid logic
        // ----------------------------------------------------

        // Get current highest bid
        ps = con.prepareStatement(
            "SELECT bidder_username, bid_amount FROM bid " +
            "WHERE artist=? AND album_title=? ORDER BY bid_amount DESC LIMIT 1"
        );
        ps.setString(1, artist);
        ps.setString(2, album);
        ResultSet rs = ps.executeQuery();

        double highestBid = bidAmount;
        String highestUser = bidder;

        if (rs.next()) {
            highestUser = rs.getString("bidder_username");
            highestBid = rs.getDouble("bid_amount");
        }
        ps.close();

        // Get increment
        ps = con.prepareStatement(
            "SELECT increment FROM Auction WHERE artist=? AND album_title=?"
        );
        ps.setString(1, artist);
        ps.setString(2, album);
        rs = ps.executeQuery();

        double increment = 1.00;
        if (rs.next()) increment = rs.getDouble("increment");
        ps.close();

        // Get all auto-bidders
        ps = con.prepareStatement(
            "SELECT bidder_username, max_bid FROM auto_bid " +
            "WHERE artist=? AND album_title=? ORDER BY max_bid DESC"
        );
        ps.setString(1, artist);
        ps.setString(2, album);
        rs = ps.executeQuery();

        java.util.List<String> users = new java.util.ArrayList<>();
        java.util.List<Double> maxes = new java.util.ArrayList<>();

        while (rs.next()) {
            users.add(rs.getString("bidder_username"));
            maxes.add(rs.getDouble("max_bid"));
        }
        ps.close();

        // Auto-bid competition
        for (int i = 0; i < users.size(); i++) {
            if (!users.get(i).equals(highestUser)) {
                // this user tries to outbid highestUser
                double challengerMax = maxes.get(i);

                if (challengerMax >= highestBid + increment) {
                    highestBid = Math.min(challengerMax, highestBid + increment);
                    highestUser = users.get(i);

                    // insert new bid
                    ps = con.prepareStatement(
                        "INSERT INTO bid (artist, album_title, bidder_username, bid_amount, bid_time) " +
                        "VALUES (?, ?, ?, ?, NOW())"
                    );
                    ps.setString(1, artist);
                    ps.setString(2, album);
                    ps.setString(3, highestUser);
                    ps.setDouble(4, highestBid);
                    ps.executeUpdate();
                    ps.close();
                }
            }
        }

        out.println("<h2>Bid placed successfully!</h2>");
        out.println("<p>Current highest bidder: " + highestUser + "</p>");
        out.println("<p>Current highest bid: $" + highestBid + "</p>");
        out.println("<a href='buyer_home.jsp'>Go Back</a>");

    } catch (Exception e) {
        out.println("<h3>Error: " + e.getMessage() + "</h3>");
        e.printStackTrace();
    }
%>
