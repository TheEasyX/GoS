if GetObjectName(GetMyHero()) ~= "KogMaw" then return end
local LocalVersion = 0.23

function Message(msg)
	print("<font color=\"#00f0ff\"><b>TheEasyX KogMaw:</b></font><font color=\"#ffffff\"> "..msg.."</font>")
end

AutoUpdater(LocalVersion, 
 true, 
 "raw.githubusercontent.com", 
 "/TheEasyX/GoS/master/TheEasyXKogMaw.ver.lua".. "?no-cache=".. math.random(9999, 1001020201), 
 "/TheEasyX/GoS/master/TheEasyXKogMaw.lua".. "?no-cache=".. math.random(9999, 1001020201), 
 SCRIPT_PATH .. "TheEasyXKogMaw.lua", 
 function() Message("Update completed successfully - 2x f6 to reload script!") return end, 
 function() Message("Loaded!") return end, 
 function() Message("Update found - starting update, please do not restart the lol client!") return end, 
 function() Message("Failed to update!") return end)

require ("DamageLib")
require("OpenPredict")

local KogMawMenu = Menu("KogMaw", "TheEasyX KogMaw")
KogMawMenu:SubMenu("Combo", "Combo")
KogMawMenu.Combo:Boolean("Q", "Use Q", true)
KogMawMenu.Combo:Boolean("W", "Use W", true)
KogMawMenu.Combo:Slider("distW", "Target Distance to Use W", 850, 500, 1200, 10)
KogMawMenu.Combo:Boolean("E", "Use E", true)
KogMawMenu.Combo:Boolean("R", "Use R", true)
KogMawMenu.Combo:Slider("MaxR", "Max R Mana Cost",80,40,400,40)
KogMawMenu:SubMenu("Harass", "Harass")
KogMawMenu.Harass:Boolean("HarassR", "Use R", true)
KogMawMenu.Harass:Slider("MaxR", "Max R Mana Cost",40,40,400,40)
KogMawMenu.Harass:Slider("Mana", "if Mana % >", 50, 0, 80, 1)
KogMawMenu:SubMenu("KS", "Killsteal")
KogMawMenu.KS:Boolean("KSR", "Killsteal with R", true)
KogMawMenu:SubMenu("Hitchance1", "Hitchance")
KogMawMenu.Hitchance1:Info("separator1", "Combo Hitchance")
KogMawMenu.Hitchance1:Slider("hitQ", "Combo Q Hitchance",25,0,100,1)
KogMawMenu.Hitchance1:Slider("hitE", "Combo E Hitchance",25,0,100,1)
KogMawMenu.Hitchance1:Slider("hitR", "Combo R Hitchance",40,0,100,1)
KogMawMenu.Hitchance1:Info("separator", "Harass Hitchance")
KogMawMenu.Hitchance1:Slider("hitRh", "Harass R Hitchance",25,0,100,1)
KogMawMenu:SubMenu("draw", "Draws")
KogMawMenu.draw:Slider("cwidth", "Circle Width", 1, 1, 10, 1)
KogMawMenu.draw:Slider("cquality", "Circle Quality", 0, 0, 8, 1)
KogMawMenu.draw:Boolean("rdraw", "Draw R", true)
KogMawMenu.draw:ColorPick("rcirclecol", "R Circle color", {255, 134, 26, 217})

tsg = TargetSelector(1700,TARGET_LESS_CAST_PRIORITY,DAMAGE_PHYSICAL,true,false)

local rangeR = 940 + (GetCastLevel(myHero, _R) * 300)
local target = GetCurrentTarget()
local Q = {delay = 0.25, speed=1425, width=70, range=1200}
local E = {delay = 0.25, speed=1300, width=120, range=1300}
local R = {delay= 0.8, speed=math.huge, width = 75, radius=150, range= rangeR}
local W = {delay= 0.1, speed=1500, width = 75, radius=150, range= 600}

OnTick(function()
local target = GetCurrentTarget()

if IOW:Mode() == "Combo" then

UseQ1()
  end
KSR()


if IOW:Mode() == "Harass" and GetPercentMP(myHero) >= KogMawMenu.Harass.Mana:Value() then
 local kogR = 40 + ( 40 * GotBuff(myHero, "kogmawlivingartillerycost"))
	if IsReady(_R) and KogMawMenu.Harass.HarassR:Value() and kogR <= KogMawMenu.Harass.MaxR:Value() then
		UseKS()
	end
end


end)
-- KS:
function KSR()	
	for _, enemy in pairs(GetEnemyHeroes()) do
		if KogMawMenu.KS.KSR:Value() and IsReady(_R) and ValidTarget(enemy, 1200) then
			if GetCurrentHP(enemy) < CalcDamage(myHero, enemy, 0, (200 + GetBonusAP(myHero))) then
				UseKS()
			end
		end
	end
end		

  function UseQ1()
    local QT = tsg:GetTarget()
    if QT ~= nil then
	  local RpI = GetCircularAOEPrediction(QT, R)
      local QpI = GetPrediction(QT, Q)
	  local EpI = GetPrediction(QT, E)
	  local kogR = (GotBuff(myHero, "kogmawlivingartillerycost") * 40) + 40
      if IsReady(_Q) and ValidTarget(GetCurrentTarget()) and KogMawMenu.Combo.Q:Value() and QpI and QpI.hitChance >=KogMawMenu.Hitchance1.hitQ:Value() / 100 and not QpI:mCollision(1) then
        CastSkillShot(_Q, QpI.castPos)

      elseif IsReady(_E) and ValidTarget(GetCurrentTarget()) and KogMawMenu.Combo.E:Value() and EpI and EpI.hitChance >=KogMawMenu.Hitchance1.hitE:Value() / 100 then
        CastSkillShot(_E, EpI.castPos)

      elseif IsReady(_R) and ValidTarget(GetCurrentTarget()) and kogR <= KogMawMenu.Combo.MaxR:Value() and KogMawMenu.Combo.R:Value() and RpI and RpI.hitChance >=KogMawMenu.Hitchance1.hitR:Value() / 100 then
        CastSkillShot(_R, RpI.castPos)

      elseif IsReady(_W) and ValidTarget(QT, KogMawMenu.Combo.distW:Value()) and KogMawMenu.Combo.W:Value() then
        CastSpell(_W)
      end
	  
	  
    end
end

  function UseKS()
    local RT = tsg:GetTarget()
    if RT ~= nil then
      local RpI = GetCircularAOEPrediction(RT, R)
      if IsReady(_R) and ValidTarget(GetCurrentTarget()) and RpI and RpI.hitChance >=KogMawMenu.Hitchance1.hitRh:Value() / 100 then
        CastSkillShot(_R, RpI.castPos)

      end
    end
end

OnDraw (function()
 if not IsDead(myHero) then
  if KogMawMenu.draw.rdraw:Value() and IsReady(_R) then 
   DrawCircle(GetOrigin(myHero), rangeR, KogMawMenu.draw.cwidth:Value(), KogMawMenu.draw.cquality:Value(), KogMawMenu.draw.rcirclecol:Value())
end
end
end)

