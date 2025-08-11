local Atlas = loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostDuckyy/UI-Libraries/refs/heads/main/Atlas%20UI%20Library/source.lua"))()

local UI = Atlas.new({
    Name = "Punch Tower X GUI"; -- script name (required)
    ConfigFolder = nil; -- folder name to save configs to, set this to nil if you want to disable configs saving
    Credit = "Made By Synapsian"; -- text to appear if player presses the "i" button on their UI (optional)
    Color = Color3.fromRGB(255,0,0); -- theme color for UI (required)
    Bind = "LeftControl"; -- keybind for toggling the UI, must be a valid KeyCode name
    -- Atlas Loader:
    UseLoader = false; -- whether to use Atlas Loader or not, if set to false than CheckKey and Discord are ignored
    FullName = "My Script Hub"; -- works if UseLoader is set to true, can be same as Name argument, shown on loader frame
})

local PlayerPage = UI:CreatePage("Players")
local PlayerSection = PlayerPage:CreateSection("Main")


local PlayerService = game:GetService('Players')
local Player = game.Players.LocalPlayer

-- // Functions \\ --
local function GiveGlove()
    for _,part in game.Players.LocalPlayer.Character:GetChildren() do
        if part:IsA('Part') then
            print("Firing touch interest with " .. part.Name)
            firetouchinterest(part,workspace['white slap'].Circle,0)
            firetouchinterest(part,workspace['white slap'].Circle,1)
            firetouchinterest(part,workspace['white slap'].Circle,0)
        end
    end
end

local function EquipGlove(preventLoop:boolean)
    local Backpack = Player.Backpack
    local Character = Player.Character or Player.CharacterAdded:Wait()

    local foundItem;

    if Character:FindFirstChildOfClass('Tool') and Character:FindFirstChildOfClass('Tool'):FindFirstChild("Event") then
        return 'Item already equipped'
    end

    for _,Item in Backpack:GetChildren() do
        if not foundItem then
            if Item:IsA('Tool') and Item:FindFirstChild("Event") then
                foundItem = Item
            end
        end
    end

    if not foundItem then
        print("Couldn't find glove in player backpack.")
        GiveGlove()
        if preventLoop then return end
        EquipGlove(true)
        return
    end

    Character.Humanoid:EquipTool(foundItem)
end

local function Slap(TargetPlayer:Player,VelocityX,VelocityY,VelocityZ)
    local Character = Player.Character
    if not Character then return 'No character' end
    EquipGlove()

    local Glove = Character:FindFirstChildOfClass('Tool')
    if not Glove or not Glove:FindFirstChild('Event') then return 'No glove or glove event found' end 
    local HitEvent = Glove.Event

    local args = {"slash",TargetPlayer.Character,vector.create(VelocityX,VelocityY,VelocityZ)}
    HitEvent:FireServer(unpack(args))
end

local function Banish(TargetPlayer:Player)
    local Character = Player.Character
    if not Character then return 'No character' end

    Slap(TargetPlayer,math.huge,math.huge,math.huge)
end

_G.SlapAura = false
local function SlapAura()
    if _G.SlapAura == false then return end

    local Targets = {}
    for _,FoundPlayer in PlayerService:GetPlayers() do
        if FoundPlayer.Character then
            Targets:insert(FoundPlayer)
        end
    end

    for _,TargetPlayer in Targets do
        task.spawn(function()
            Slap(TargetPlayer,10,10,10)
        end)
    end

    task.wait(0.1)
    SlapAura()
end

-- // Elements \\ -- (Type, Name, State, Callback)
_G.CurrentTargetPlayer = nil
local TargetPlayerDropdown = PlayerSection:CreateDropdown({
    Name = 'Target Player';
    Callback = function(selectedPlayer)
        _G.CurrentTargetPlayer = PlayerService:FindFirstChild(selectedPlayer)
    end;
    Options = {};
})

local function UpdateTargetPlayerDropdown()
   local Players = {}

    for _,FoundPlayer in PlayerService:GetPlayers() do
        table.insert(Players,FoundPlayer.Name)
    end 

    TargetPlayerDropdown:Update(Players)
end
UpdateTargetPlayerDropdown()

PlayerService.PlayerAdded:Connect(function(newPlayer:Player)
    UpdateTargetPlayerDropdown()
end)

PlayerService.PlayerRemoving:Connect(function(removedPlayer:Player)
    UpdateTargetPlayerDropdown()
end)

PlayerSection:CreateButton({
    Name = "Banish";
    Callback = function()
        Banish(_G.CurrentTargetPlayer)
    end
})

PlayerSection:CreateToggle({
    Name = 'Slap Aura';
    Flag = 'SlapAura';
    Default = false;
    Callback = function()
        if _G.SlapAura then
            _G.SlapAura = false
        else
            _G.SlapAura = true
            SlapAura()
        end
    end
})