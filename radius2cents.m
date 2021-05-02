function cents = radius2cents(radius)
    error = 1.5
    
    if abs(radius - 57) < error
        cents = 1
    elseif abs(radius - 67) < error
        cents = 2
    elseif abs(radius - 75) < error
        cents = 5
    elseif abs(radius - 70) < error
        cents = 10
    elseif abs(radius - 78.5) < error
        cents = 20
    elseif abs(radius - 85) < error
        cents = 50
    elseif abs(radius - 82) < error
        cents = 100
    else
        cents = 0
    end
end