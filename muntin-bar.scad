/**
 * Muntin Bar Generator — 3D Printed Door Grid
 * Parametric model for MakerWorld
 *
 * Companion calculator: https://emorin310.github.io/muntin-calculator/
 *
 * Pieces interlock at 4-way intersections via half-lap joints
 * with puzzle tabs for positive Z-locking.
 * H bars keep the bottom half at connectors (tabs protrude up).
 * V bars keep the top half at connectors (slots receive tabs).
 */

/* [Window] */
// Width of glass pane (mm)
pane_width = 530;
// Height of glass pane (mm)
pane_height = 1590;

/* [Bar] */
// Width of bars at intersections (mm)
bar_width = 20;
// Thickness of bars (mm)
bar_thickness = 6;

/* [Printer] */
// Maximum print bed length (mm)
max_bed = 250;

/* [Connector] */
// Puzzle tab width (mm)
tab_w = 5;
// Puzzle tab length along bar (mm)
tab_l = 5;
// Puzzle tab height / depth (mm)
tab_h = 2;
// Print clearance for slot fit (mm)
clearance = 0.3;

/* [Piece Selection] */
// Which piece to generate
piece = "all"; // [all:All Types, h_center:Horizontal Center, h_edge:Horizontal Edge, v_center:Vertical Center, v_edge:Vertical Edge]

/* [Hidden] */

// --- Auto-calculate minimum bars to fit print bed ---
max_flat = max_bed - bar_width;

v_bars = max(1, ceil((pane_width - max_flat) / (max_flat + bar_width)));
h_bars = max(1, ceil((pane_height - max_flat) / (max_flat + bar_width)));

// Flat lengths between intersections
h_flat = (pane_width - v_bars * bar_width) / (v_bars + 1);
v_flat = (pane_height - h_bars * bar_width) / (h_bars + 1);

// Piece total lengths
h_center_len = h_flat + bar_width;      // connector both ends
h_edge_len   = h_flat + bar_width / 2;  // connector one end
v_center_len = v_flat + bar_width;
v_edge_len   = v_flat + bar_width / 2;

// Piece counts
cols = v_bars + 1;
rows = h_bars + 1;
n_h_edge   = h_bars * 2;
n_h_center = h_bars * max(0, v_bars - 1);
n_v_edge   = v_bars * 2;
n_v_center = v_bars * max(0, h_bars - 1);
n_total    = n_h_edge + n_h_center + n_v_edge + n_v_center;

// Half dimensions
half = bar_thickness / 2;
hw   = bar_width / 2;
e    = 0.01;

// Slot dimensions (tab + clearance)
sl_w = tab_w + clearance;
sl_l = tab_l + clearance;
sl_h = tab_h + clearance;

// --- Console output ---
echo(str("Grid: ", cols, " x ", rows, " panes (",
         v_bars, " vertical x ", h_bars, " horizontal bars)"));
echo(str("h_flat = ", h_flat, " mm   v_flat = ", v_flat, " mm"));
echo(str("H center: ", h_center_len, " mm x ", n_h_center, " pcs"));
echo(str("H edge:   ", h_edge_len,   " mm x ", n_h_edge,   " pcs"));
echo(str("V center: ", v_center_len, " mm x ", n_v_center, " pcs"));
echo(str("V edge:   ", v_edge_len,   " mm x ", n_v_edge,   " pcs"));
echo(str("Total pieces: ", n_total));
echo(str("Verify W: ", cols, "x", h_flat, " + ", v_bars, "x", bar_width,
         " = ", cols * h_flat + v_bars * bar_width, " mm (expect ", pane_width, ")"));
echo(str("Verify H: ", rows, "x", v_flat, " + ", h_bars, "x", bar_width,
         " = ", rows * v_flat + h_bars * bar_width, " mm (expect ", pane_height, ")"));

// =====================================================
// Connector primitives
// =====================================================

// Tab: rectangular peg protruding UP from half-lap surface
// Place at (center_x, center_y, half) on H pieces
module tab() {
    translate([-tab_l/2, -tab_w/2, 0])
        cube([tab_l, tab_w, tab_h]);
}

// Slot: matching pocket cut INTO V piece from half-lap surface
// Place at (center_x, center_y, half) on V pieces
module slot() {
    translate([-sl_l/2, -sl_w/2, 0])
        cube([sl_l, sl_w, sl_h + e]);
}

// =====================================================
// Piece modules
// =====================================================

// Horizontal center: half-lap (bottom half) + tabs at both ends
module h_center() {
    // Center piece on origin
    translate([-h_center_len/2, -bar_width/2, 0])
    union() {
        difference() {
            cube([h_center_len, bar_width, bar_thickness]);
            // Left connector — remove top half
            translate([-e, -e, half])
                cube([hw + e, bar_width + 2*e, half + e]);
            // Right connector — remove top half
            translate([h_center_len - hw, -e, half])
                cube([hw + e, bar_width + 2*e, half + e]);
        }
        // Left connector tabs (one per crossing V bar)
        translate([hw/2, hw/2, half]) tab();
        translate([hw/2, bar_width - hw/2, half]) tab();
        // Right connector tabs
        translate([h_center_len - hw/2, hw/2, half]) tab();
        translate([h_center_len - hw/2, bar_width - hw/2, half]) tab();
    }
}

// Horizontal edge: half-lap + tabs at connector end only
module h_edge() {
    translate([-h_edge_len/2, -bar_width/2, 0])
    union() {
        difference() {
            cube([h_edge_len, bar_width, bar_thickness]);
            // Connector — remove top half
            translate([h_flat, -e, half])
                cube([hw + e, bar_width + 2*e, half + e]);
        }
        // Connector tabs
        translate([h_flat + hw/2, hw/2, half]) tab();
        translate([h_flat + hw/2, bar_width - hw/2, half]) tab();
    }
}

// Vertical center: half-lap (top half) + slots at both ends
module v_center() {
    translate([-bar_width/2, -v_center_len/2, 0])
    difference() {
        cube([bar_width, v_center_len, bar_thickness]);
        // Bottom connector — remove bottom half
        translate([-e, -e, -e])
            cube([bar_width + 2*e, hw + e, half + e]);
        // Top connector — remove bottom half
        translate([-e, v_center_len - hw, -e])
            cube([bar_width + 2*e, hw + e, half + e]);
        // Bottom connector slots (one per crossing H bar)
        translate([hw/2, hw/2, half]) slot();
        translate([bar_width - hw/2, hw/2, half]) slot();
        // Top connector slots
        translate([hw/2, v_center_len - hw/2, half]) slot();
        translate([bar_width - hw/2, v_center_len - hw/2, half]) slot();
    }
}

// Vertical edge: half-lap + slots at connector end only
module v_edge() {
    translate([-bar_width/2, -v_edge_len/2, 0])
    difference() {
        cube([bar_width, v_edge_len, bar_thickness]);
        // Connector — remove bottom half
        translate([-e, v_flat, -e])
            cube([bar_width + 2*e, hw + e, half + e]);
        // Connector slots
        translate([hw/2, v_flat + hw/2, half]) slot();
        translate([bar_width - hw/2, v_flat + hw/2, half]) slot();
    }
}

// =====================================================
// Layout — all pieces centered on build plate origin
// =====================================================
gap = 10;

if (piece == "all") {
    // Lay out all 4 types side by side, centered on origin
    total_y = 4 * bar_width + 3 * gap;
    offset_y = -total_y / 2 + bar_width / 2;

    translate([0, offset_y, 0])
        color("SaddleBrown") h_center();
    translate([0, offset_y + bar_width + gap, 0])
        color("Peru") h_edge();
    translate([0, offset_y + (bar_width + gap) * 2, 0])
        color("Sienna") v_center();
    translate([0, offset_y + (bar_width + gap) * 3, 0])
        color("Chocolate") v_edge();
} else if (piece == "h_center") {
    color("SaddleBrown") h_center();
} else if (piece == "h_edge") {
    color("Peru") h_edge();
} else if (piece == "v_center") {
    color("Sienna") v_center();
} else if (piece == "v_edge") {
    color("Chocolate") v_edge();
}
