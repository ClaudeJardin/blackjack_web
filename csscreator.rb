
Dir.chdir 'public/css/'

read_file = 'basecss/basecss.css'
output_file = 'gamestyle.css'

max_waiting_unit = 40
unit_time = 0.5

styles = ['#state_blackjack_?.state_blackjack_style', '#state_busted_?.state_busted_style', '#state_stay_?.state_stay_style', 
          '#front_?.player_front_style', '#back_?.player_back_style', '#player_hit_stay_?.player_hit_stay_style', '#speech_?.speech', 
		  '#front_?.dealer_front_style', '#back_?.dealer_back_style', '#back_0_1_?.player_back_style', '#back_0_2_?.player_back_style',
		  '#front_0_1_?.player_front_style', '#front_0_2_?.player_front_style', '#dealer_result_?.dealer_result_style',
		  '#player_result_?.won_result_style_1', '#player_result_?.lost_result_style_1', '#player_result_?.tie_result_style_1',
		  '#player_result_?.won_result_style_2', '#player_result_?.lost_result_style_2', '#player_result_?.tie_result_style_2',
		  '#player_result_?.won_result_style_3', '#player_result_?.lost_result_style_3', '#player_result_?.tie_result_style_3',
		  '#player_result_?.won_result_style_4', '#player_result_?.lost_result_style_4', '#player_result_?.tie_result_style_4',
		  '#try_again_?.try_again_style']
contents = ['show_up 0.5s', 'show_up 0.5s', 'show_up 0.5s', 'first_front 0.5s', 'first_back 0.5s', 'show_up 0.5s', 
            'show_up 0.5s, fade_out 0.5s', 'first_front 0.5s', 'first_back 0.5s', 
			'dealer_first_anim 0.5s, first_back 0.5s', 'dealer_first_anim 0.5s, first_back 0.5s',
			'dealer_first_anim 0.5s, first_front 0.5s', 'dealer_first_anim 0.5s, first_front 0.5s', 'show_up 0.5s',
			'show_up 0.5s', 'show_up 0.5s', 'show_up 0.5s',
			'show_up 0.5s', 'show_up 0.5s', 'show_up 0.5s',
			'show_up 0.5s', 'show_up 0.5s', 'show_up 0.5s',
			'show_up 0.5s', 'show_up 0.5s', 'show_up 0.5s',
			'show_up 0.5s']
File.open(output_file, 'w') do |f_out|
  #Put default css settings 
  File.open(read_file, 'r') do |f_in|
    while (line = f_in.gets)
	  f_out.puts(line)
    end
  end
  
  styles.length.times do |k|
	action = contents[k]
    max_waiting_unit.times do |i|
	  style = styles[k].clone
	  style['?'] = (i + 1).to_s
	  f_out.puts style + '{'
	  f_out.puts '  -webkit-animation: ' + action + ';'
	  f_out.puts '  animation: ' + action + ';'
	  f_out.puts '  -webkit-animation-fill-mode: forwards;'
      f_out.puts '  animation-fill-mode: forwards;'
      #f_out.puts '  -webkit-animation-delay: 0.5s;'
	  
	  delay_string = ((i + 1).to_f * unit_time).to_s + 's'
	  if k == 6
	    delay_string = delay_string + ', ' + ((i + 2).to_f * unit_time).to_s + 's'
	  elsif k == 9 || k == 11
	    delay_string = '0s, ' + ((i + 1).to_f * unit_time).to_s + 's'
	  elsif k == 10 || k == 12
	    delay_string = '0.5s, ' + ((i + 1).to_f * unit_time).to_s + 's'
	  end
	  
      f_out.puts '  animation-delay: ' + delay_string + ';'
	  f_out.puts '  -webkit-animation-delay: ' + delay_string + ';'
	  f_out.puts '}'
	end
  end
end

