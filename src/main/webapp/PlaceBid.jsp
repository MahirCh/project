<%@ page import="java.sql.*" %>
<%
    // ---------------------------
    // 1. Get parameters safely
    // ---------------------------
    String aucIdStr  = request.getParameter("auction_id");
    String bidStr    = request.getParameter("bid_amount");
    String maxStr    = request.getParameter("upper_limit");
    String bidder    = (String) session.getAttribute("user");

    if (aucIdStr == null || bidStr == null || bidder == null) {
        out.println("<h3>Error: Missing parameters or session expired.</h3>");
        return;
    }

    int aucId;
    double bidAmount;
    Double maxBid = null;

    try {
        aucId = Integer.parseInt(aucIdStr);
        bidAmount = Double.parseDouble(bidStr);

        if (maxStr != null && !maxStr.trim().isEmpty()) {
            maxBid = Double.parseDouble(maxStr);
        }
    } catch (NumberFormatException e) {
        out.println("<h3>Error: Invalid numeric input.</h3>");
        return;
    }

    // ---------------------------
    // 2. DB connection
    // ---------------------------
    try {
        Class.forName("com.mysql.jdbc.Driver");
    } catch (ClassNotFoundException e) {
        out.println("<h3>Error: JDBC Driver not found.</h3>");
        return;
    }

    try (Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/projectdb", "root", "school")) {

        // ---------------------------
        // 3. Insert user's immediate bid
        // ---------------------------
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO bid (auc_id, username, bid_amount, bid_time) VALUES (?, ?, ?, NOW())")) {
            ps.setInt(1, aucId);
            ps.setString(2, bidder);
            ps.setDouble(3, bidAmount);
            ps.executeUpdate();
        }

        // ---------------------------
        // 4. Insert/update auto-bid
        // ---------------------------
        if (maxBid != null && maxBid > bidAmount) {
            // delete existing auto-bid for this user
            try (PreparedStatement ps = con.prepareStatement(
                    "DELETE FROM auto_bid WHERE auction_id=? AND bidder_username=?")) {
                ps.setInt(1, aucId);
                ps.setString(2, bidder);
                ps.executeUpdate();
            }

            // insert new auto-bid
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO auto_bid (auction_id, bidder_username, max_bid) VALUES (?, ?, ?)")) {
                ps.setInt(1, aucId);
                ps.setString(2, bidder);
                ps.setDouble(3, maxBid);
                ps.executeUpdate();
            }
        }

        // ---------------------------
        // 5. Get auction increment
        // ---------------------------
        double increment = 1.0;
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT increment FROM Auction WHERE auction_id=?")) {
            ps.setInt(1, aucId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) increment = rs.getDouble("increment");
            }
        }

        // ---------------------------
        // 6. Auto-bid loop
        // ---------------------------
        boolean changed = true;
        while (changed) {
            changed = false;

            // get current top bid
            String topUser = null;
            double topBid = 0.0;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT username, bid_amount FROM bid WHERE auc_id=? ORDER BY bid_amount DESC, bid_time ASC LIMIT 1")) {
                ps.setInt(1, aucId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        topUser = rs.getString("username");
                        topBid = rs.getDouble("bid_amount");
                    }
                }
            }

            if (topUser == null) break; // no bids, safety check

            // check other auto-bids
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT bidder_username, max_bid FROM auto_bid WHERE auction_id=? AND bidder_username<>? ORDER BY max_bid DESC")) {
                ps.setInt(1, aucId);
                ps.setString(2, topUser);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String challenger = rs.getString("bidder_username");
                        double challengerMax = rs.getDouble("max_bid");

                        if (challengerMax >= topBid + increment) {
                            double newBid = Math.min(challengerMax, topBid + increment);

                            try (PreparedStatement ps2 = con.prepareStatement(
                                    "INSERT INTO bid (auc_id, username, bid_amount, bid_time) VALUES (?, ?, ?, NOW())")) {
                                ps2.setInt(1, aucId);
                                ps2.setString(2, challenger);
                                ps2.setDouble(3, newBid);
                                ps2.executeUpdate();
                            }

                            changed = true;
                            break; // only place one bid per loop iteration
                        }
                    }
                }
            }
        }

        // ---------------------------
        // 7. Display final highest bid
        // ---------------------------
        String finalUser = null;
        double finalBid = 0.0;
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT username, bid_amount FROM bid WHERE auc_id=? ORDER BY bid_amount DESC, bid_time ASC LIMIT 1")) {
            ps.setInt(1, aucId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    finalUser = rs.getString("username");
                    finalBid = rs.getDouble("bid_amount");
                    String sql20= "Insert into max_bids(auc_id, username, bid_amount) values (?, ?, ?)";
                    PreparedStatement ps2=con.prepareStatement(sql20);
                    ps2.setInt(1, aucId);
                    ps2.setString(2, finalUser);
                    ps2.setDouble(3, finalBid);
                    ps2.executeUpdate();
                }
            }
        }

        out.println("<h2>Bid Placed!</h2>");
        out.println("<p>Highest bidder: " + finalUser + "</p>");
        out.println("<p>Highest bid: $" + finalBid + "</p>");
        out.println("<a href='success.jsp'>Go Home</a>");

    } catch (SQLException e) {
        out.println("<h3>Database Error: " + e.getMessage() + "</h3>");
        e.printStackTrace();
    }
%>
