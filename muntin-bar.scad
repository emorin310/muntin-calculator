/**
 * Muntin Bar Generator — 3D Printed Door Grid
 * Parametric model for MakerWorld
 *
 * Companion calculator: https://emorin310.github.io/muntin-calculator/
 *
 * Pieces interlock at 4-way intersections via half-lap joints.
 * Horizontal bars keep the bottom half at connectors;
 * vertical bars keep the top half — they nest flush.
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
n_h_center = h_bars * (v_bars - 1);
n_v_edge   = v_bars * 2;
n_v_center = v_bars * (h_bars - 1);
n_total    = n_h_edge + n_h_center + n_v_edge + n_v_center;

// Half dimensions
half = bar_thickness / 2;
hw   = bar_width / 2;
e    = 0.01; // epsilon for clean boolean ops

// --- Console output ---
echo(str("Grid: ", cols, " × ", rows, " panes (",
         v_bars, " vertical × ", h_bars, " horizontal bars)"));
echo(str("h_flat = ", h_flat, " mm   v_flat = ", v_flat, " mm"));
echo(str("H center: ", h_center_len, " mm × ", n_h_center, " pcs"));
echo(str("H edge:   ", h_edge_len,   " mm × ", n_h_edge,   " pcs"));
echo(str("V center: ", v_center_len, " mm × ", n_v_center, " pcs"));
echo(str("V edge:   ", v_edge_len,   " mm × ", n_v_edge,   " pcs"));
echo(str("Total pieces: ", n_total));

// Verify dimensions
echo(str("Verify W: ", cols, "×", h_flat, " + ", v_bars, "×", bar_width,
         " = ", cols * h_flat + v_bars * bar_width, " mm (expect ", pane_width, ")"));
echo(str("Verify H: ", rows, "×", v_flat, " + ", h_bars, "×", bar_width,
         " = ", rows * v_flat + h_bars * bar_width, " mm (expect ", pane_height, ")"));

// =====================================================
// Piece modules
// =====================================================

// Horizontal center piece — connector (bottom half) on both ends
module h_center() {
    difference() {
        cube([h_center_len, bar_width, bar_thickness]);
        // Left connector notch — remove top half
        translate([-e, -e, half])
            cube([hw + e, bar_width + 2*e, half + e]);
        // Right connector notch — remove top half
        translate([h_center_len - hw, -e, half])
            cube([hw + e, bar_width + 2*e, half + e]);
    }
}

// Horizontal edge piece — connector on one end, flat frame end on other
module h_edge() {
    difference() {
        cube([h_edge_len, bar_width, bar_thickness]);
        // Connector notch at far end — remove top half
        translate([h_flat, -e, half])
            cube([hw + e, bar_width + 2*e, half + e]);
    }
}

// Vertical center piece — connector (top half) on both ends
module v_center() {
    difference() {
        cube([bar_width, v_center_len, bar_thickness]);
        // Bottom connector notch — remove bottom half
        translate([-e, -e, -e])
            cube([bar_width + 2*e, hw + e, half + e]);
        // Top connector notch — remove bottom half
        translate([-e, v_center_len - hw, -e])
            cube([bar_width + 2*e, hw + e, half + e]);
    }
}

// Vertical edge piece — connector on one end, flat frame end on other
module v_edge() {
    difference() {
        cube([bar_width, v_edge_len, bar_thickness]);
        // Connector notch at far end — remove bottom half
        translate([-e, v_flat, -e])
            cube([bar_width + 2*e, hw + e, half + e]);
    }
}

// =====================================================
// Layout
// =====================================================
gap = 8;

if (piece == "all") {
    // One of each type, labeled by position
    color("SaddleBrown") h_center();
    translate([0, bar_width + gap, 0])
        color("Peru") h_edge();
    translate([0, (bar_width + gap) * 2, 0])
        color("Sienna") v_center();
    translate([0, (bar_width + gap) * 3, 0])
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
