class DeafGrandma
  RESPONSES = [
    "NO, NOT SINCE #{rand(22) + 1929}!!!"
  ]

  def respond(incoming_text)
    if incoming_text.include?("BYE")
      @response = "BYE NOW, PRECIOUS!!! DON'T BE A STRANGER!"
    elsif incoming_text != incoming_text.upcase
      @response = "WHAT WAS THAT???? SPEAK UP!!!"
    else
      @response = RESPONSES.sample
    end
  end

end
