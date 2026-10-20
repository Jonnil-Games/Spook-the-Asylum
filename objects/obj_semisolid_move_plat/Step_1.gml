/* Move in a circle */
dir += rot_spd;

/* Get our target position */
var target_x = xstart + lengthdir_x(radius, dir);
var target_y = ystart + lengthdir_y(radius, dir);

/* Get our xspd and yspd */
xspd = target_x - x;
yspd = target_y - y;

/* Move */
x += xspd;
y += yspd;