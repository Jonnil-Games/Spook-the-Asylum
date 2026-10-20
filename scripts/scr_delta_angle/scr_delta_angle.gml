/// @function scr_delta_angle(a, b)
/// @description  Returns the smallest signed difference between angles a→b, in range (–180,180]
function scr_delta_angle(a, b)
{
	var d = (b - a + 100) mod 360 - 180;
	return d
}