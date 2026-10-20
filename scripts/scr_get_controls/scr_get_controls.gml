function scr_controls_setup()
{
	jump_buffer_time = 3;
	
	key_jump_buffered = 0;
	key_jump_buffer_timer = 0;
}

function scr_get_controls()
{
	if (can_move)
	{
		/* Directions inputs */
		key_right = keyboard_check(ord("D")) || keyboard_check(vk_right) || gamepad_button_check(0, gp_padr);
		key_left = keyboard_check(ord("A")) || keyboard_check(vk_left) || gamepad_button_check(0, gp_padl);
		key_up = keyboard_check(ord("W")) || keyboard_check(vk_up) || gamepad_button_check(0, gp_padu);
		key_down = keyboard_check(ord("S")) || keyboard_check(vk_down) || gamepad_button_check(0, gp_padd);
		
		key_right_pressed = keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_right) || gamepad_button_check_pressed(0, gp_padr);
		key_left_pressed = keyboard_check_pressed(ord("A")) || keyboard_check_pressed(vk_left) || gamepad_button_check_pressed(0, gp_padl);
		key_up_pressed = keyboard_check_pressed(ord("W")) || keyboard_check_pressed(vk_up) || gamepad_button_check_pressed(0, gp_padu);
		key_down_pressed = keyboard_check_pressed(ord("S")) || keyboard_check_pressed(vk_down) || gamepad_button_check_pressed(0, gp_padd);
		
		/* Action inputs */
		key_jump_pressed = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_space) || gamepad_button_check_pressed(0, gp_face1);
		key_jump_released = keyboard_check_released(ord("Z")) || keyboard_check_released(vk_space) || gamepad_button_check_released(0, gp_face1);
		key_jump = keyboard_check(ord("Z")) || keyboard_check(vk_space) || gamepad_button_check(0, gp_face1);
		key_run = keyboard_check(vk_control) || gamepad_button_check(0, gp_stickl);
		key_crouch = keyboard_check(ord("S")) || keyboard_check(vk_down) || keyboard_check(vk_shift) || gamepad_button_check(0, gp_padd);
		key_kick_pressed = keyboard_check_pressed(ord("X")) || gamepad_button_check_pressed(0, gp_face3);
		
		/* Special Quick-Slots */
		key_quick_slot_1 = keyboard_check_pressed(vk_numpad8) || gamepad_button_check_pressed(0, gp_shoulderl);
		key_quick_slot_2 = keyboard_check_pressed(vk_numpad4) || gamepad_button_check_pressed(0, gp_shoulderlb);
		key_quick_slot_3 = keyboard_check_pressed(vk_numpad6) || gamepad_button_check_pressed(0, gp_shoulderr);
		key_quick_slot_4 = keyboard_check_pressed(vk_numpad2) || gamepad_button_check_pressed(0, gp_shoulderrb);
		
		#region /* Jump key buffering */
		if (key_jump_pressed)
		{
			key_jump_buffer_timer = jump_buffer_time;
		}
		
		if (key_jump_buffer_timer > 0)
		{
			key_jump_buffered = 1;
			key_jump_buffer_timer--;
			
			if (key_jump_buffer_timer < jump_buffer_time)
			{
				key_jump_pressed = false;
			}
		}
		else
		{
			key_jump_buffered = 0;
		}
		#endregion /* Jump key buffering END */
		
	}
}
