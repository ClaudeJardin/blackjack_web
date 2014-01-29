def show_title title, sign_char
  title_width = 76
  title_length = title.length
  margin = (title_width - title_length - 2) / 2
  margin_string = (margin > 0)? sign_char * margin : ''
  if title.length > 0
    puts (margin_string + ' ' + title + ' ' + margin_string).center(title_width)
  else
    puts sign_char * title_width
  end
end

def show_text_banner (text, height)
  sign_char = '-'
  half = height / 2
  i = 0
  while i < half
    show_title('', sign_char)
	i = i + 1
  end
  show_title(text, sign_char)
  i = 0
  while i < half
    show_title('', sign_char)
	i = i + 1
  end  
  puts ''
end

def thinking sec
  i = 0
  while i < sec
    sleep(1)
    print '.'
	i = i + 1
  end
end