-- ### HTML TEXT CONVERTION ### --
local html = {
    -- start tags
    ['<h1>'] = '#',
    ['<h2>'] = '##',
    ['<h3>'] = '###',
    ['<h4>'] = '####',
    ['<h5>'] = '#####',
    ['<h6>'] = '######',
    ['<b>'] = '**',
    ['<bold>'] = '**',
    ['<strong>'] = '**',
    ['<i>'] = '*',
    -- end tags
    ['</h1>'] = '',
    ['</h2>'] = '',
    ['</h3>'] = '',
    ['</h4>'] = '',
    ['</h5>'] = '',
    ['</h6>'] = '',
    ['</b>'] = '**',
    ['</bold>'] = '**',
    ['</strong>'] = '**',
    ['</i>'] = '*',
    ['<br>'] = '',
}

function ConvertText(string)
    if string == '' then return false end
    if not string then return false end

    if string:match("<img(.*)>") then
        local match = string:match("<img(.*)>")
        local beg, final = string.find(string, ">")
        local after_string = string.sub(string, final + 1)
        string = after_string
    else
        for k, v in pairs(html) do
            string = string.gsub(string, k, v)
        end
    end
    return string
end