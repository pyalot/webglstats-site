alphabet = '0123456789abcdef'
lookup = {}
for c, i in alphabet
    lookup[c] = i

exports.encode = (data) ->
    string = ''
    for num in data
        a = Math.floor(num/16)
        b = num % 16
        string += alphabet[a]
        string += alphabet[b]
    return string

exports.decode = (string) ->
    data = new Uint8Array(string.length/2)
    for i in [0...string.length] by 2
        a = lookup[string[i+0]]
        b = lookup[string[i+1]]
        data[i/2] = a*16 + b
    return data
