-- Simple AI text detector in Lua

local filename = "test_texts.txt"
local file = io.open(filename, "r")

if not file then
    print("Cannot open file: " .. filename)
    return
end

local correct = 0
local total = 0

-- Helper functions
local function splitWords(str)
    local words = {}
    for word in str:gmatch("%S+") do
        table.insert(words, word)
    end
    return words
end

local function avgWordLength(words)
    if #words == 0 then return 0 end
    local sum = 0
    for _, w in ipairs(words) do
        sum = sum + #w
    end
    return sum / #words
end

local function wordDiversity(words)
    if #words == 0 then return 0 end
    local seen = {}
    for _, w in ipairs(words) do
        seen[w] = true
    end
    local uniqueCount = 0
    for _ in pairs(seen) do uniqueCount = uniqueCount + 1 end
    return uniqueCount / #words
end

local function punctDensity(text, wordCount)
    if wordCount == 0 then return 0 end
    local count = 0
    for c in text:gmatch("[%p]") do
        count = count + 1
    end
    return count / wordCount
end

-- Process each line
for line in file:lines() do
    if line ~= "" then
        total = total + 1

        local label, text = line:match("^(%w+):%s*(.+)$")
        if label and text then
            local words = splitWords(text)
            local awl = avgWordLength(words)
            local wd = wordDiversity(words)
            local pd = punctDensity(text, #words)

            -- Heuristic scoring
            local score = 0
            if awl < 5 then score = score + 1 end
            if wd < 0.6 then score = score + 1 end
            if pd < 0.1 then score = score + 1 end

            local prediction = (score >= 2) and "AI" or "Human"

            print(string.format("Text: %.50s... Prediction: %s, Ground Truth: %s", text, prediction, label))

            if prediction == label then
                correct = correct + 1
            end
        end
    end
end

file:close()

local accuracy = (correct / total) * 100
print(string.format("\nAccuracy over %d texts: %.2f%%", total, accuracy))
