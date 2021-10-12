local jc = jrequire 'jc'

local ostrap = {}

function ostrap.getValidRandom(collection)
    local array = jc.filter(collection, function(x) return x.Enabled == 1 end)
    return array[math.random(#array)]
end

return ostrap