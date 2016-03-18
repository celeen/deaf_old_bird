class DeafGrandma
  RESPONSES = [
    "NO, NOT SINCE #{rand(22) + 1929}!!!"
  ]

  def build_response_to(incoming_text)
    incoming_text = sanitize_input(incoming_text)

    if incoming_text.include?("BYE")
      @response = "BYE NOW, PRECIOUS!!! DON'T BE A STRANGER!"
    elsif incoming_text != incoming_text.upcase
      @response = "WHAT WAS THAT???? SPEAK UP!!!"
    else
      @response = RESPONSES.sample
    end
  end

  def sanitize_input(input)
    input.split(" ").reject{ |word| word[0] == "@" }.join
  end

end
