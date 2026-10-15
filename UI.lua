local _, F = ...
local U={}; F.UI=U
local cream={.94,.88,.72}; local green={.46,.72,.53}
local function text(parent,size,x,y,width)
 local t=F.LocalizeText(parent:CreateFontString(nil,"OVERLAY"))
 -- Russian labels need a Cyrillic font even on an English client.
 if not t:SetFont("Fonts\\FRIZQT___CYR.TTF",size) then t:SetFont("Fonts\\ARIALN.TTF",size) end
 t:SetTextColor(unpack(cream)); t:SetJustifyH("LEFT")
 t:SetPoint("TOPLEFT",x,y); if width then t:SetWidth(width) end
 return t
end
local function box(name,w,h)
 local f=CreateFrame("Frame",name,UIParent,"BackdropTemplate")
 f:SetSize(w,h); f:SetPoint("CENTER"); f:SetClampedToScreen(true)
 f:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",tile=false,edgeSize=16,insets={left=4,right=4,top=4,bottom=4}})
 f:SetBackdropColor(.075,.09,.075,.97); f:SetBackdropBorderColor(.55,.45,.26,.9)
 f:SetFrameStrata("DIALOG"); f:EnableMouse(true); f:SetMovable(true); f:RegisterForDrag("LeftButton")
 f:SetScript("OnDragStart",function(self) self:StartMoving() end)
 f:SetScript("OnDragStop",function(self) self:StopMovingOrSizing() end)
 f:Hide(); return f
end
local function button(p,label,x,y,w,fn)
 local b=F.LocalizeText(CreateFrame("Button",nil,p,"UIPanelButtonTemplate")); b:SetSize(w or 110,26); b:SetPoint("TOPLEFT",x,y)
 b:SetText(label); b:SetScript("OnClick",fn); return b
end
local function check(p,label,x,y,checked,fn)
 local c=CreateFrame("CheckButton",nil,p,"UICheckButtonTemplate"); c:SetSize(26,26); c:SetPoint("TOPLEFT",x,y)
 c:SetChecked(checked); local t=text(c,13,30,-6,260); t:SetText(label)
 c:SetScript("OnClick",function(self) fn(self:GetChecked() and true or false) end); return c
end
local function edit(p,value,x,y,w)
 local e=CreateFrame("EditBox",nil,p,"InputBoxTemplate"); e:SetSize(w,25); e:SetPoint("TOPLEFT",x,y)
 e:SetAutoFocus(false); e:SetText(tostring(value)); e:SetScript("OnEscapePressed",function(self) self:ClearFocus() end)
 return e
end
local function rounded(parent,w,h,r,color)
 local function piece(x,y,pw,ph,uv)
  local t=parent:CreateTexture(nil,"BACKGROUND");t:SetSize(pw,ph);t:SetPoint("TOPLEFT",x,-y)
  if uv then
   t:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask");t:SetTexCoord(unpack(uv));t:SetVertexColor(unpack(color))
  else t:SetColorTexture(unpack(color)) end
 end
 piece(r,0,w-2*r,h);piece(0,r,r,h-2*r);piece(w-r,r,r,h-2*r)
 piece(0,0,r,r,{0,.5,0,.5});piece(w-r,0,r,r,{.5,1,0,.5})
 piece(0,h-r,r,r,{0,.5,.5,1});piece(w-r,h-r,r,r,{.5,1,.5,1})
end
local function pill(parent,label,x,y,w,color,fn)
 local b=CreateFrame("Button",nil,parent);b:SetSize(w,27);b:SetPoint("TOPLEFT",x,y)
 rounded(b,w,27,13,color)
 local caption=text(b,13,0,-6,w);caption:SetJustifyH("CENTER");caption:SetText(label)
 b:SetScript("OnClick",fn);b:SetScript("OnEnter",function(self) self:SetAlpha(.8) end)
 b:SetScript("OnLeave",function(self) self:SetAlpha(1) end);return b,caption
end
function U:BuildBannerMotion()
 self.bannerIn=self.nudge:CreateAnimationGroup()
 local grow=self.bannerIn:CreateAnimation("Scale")
 grow:SetOrigin("CENTER",0,0);grow:SetScaleFrom(.08,.08);grow:SetScaleTo(1.04,1.04)
 grow:SetDuration(.285);grow:SetOrder(1);grow:SetSmoothing("OUT")
 local appear=self.bannerIn:CreateAnimation("Alpha")
 appear:SetFromAlpha(0);appear:SetToAlpha(1);appear:SetDuration(.285);appear:SetOrder(1)
 local settle=self.bannerIn:CreateAnimation("Scale")
 settle:SetOrigin("CENTER",0,0);settle:SetScaleFrom(1,1);settle:SetScaleTo(1/1.04,1/1.04)
 settle:SetDuration(.12);settle:SetOrder(2);settle:SetSmoothing("IN_OUT")
 self.bannerIn:SetScript("OnFinished",function() U.nudge:SetAlpha(1) end)
 self.bannerOut=self.nudge:CreateAnimationGroup()
 local fade=self.bannerOut:CreateAnimation("Alpha")
 fade:SetFromAlpha(1);fade:SetToAlpha(0);fade:SetDuration(.12);fade:SetOrder(1)
 self.bannerOut:SetScript("OnFinished",function() U.nudge:Hide();U.nudge:SetAlpha(1) end)
end
function U:RevealBanner()
 self.bannerOut:Stop();self.bannerIn:Stop();self.nudge:SetAlpha(1);self.nudge:Show();self.bannerIn:Play()
end
function U:HideBanner(animate)
 if animate and self.nudge:IsShown() then
  if not self.bannerOut:IsPlaying() then self.bannerIn:Stop();self.nudge:SetAlpha(1);self.bannerOut:Play() end
 else self.bannerIn:Stop();self.bannerOut:Stop();self.nudge:Hide();self.nudge:SetAlpha(1) end
end
function U:PositionBanner()
 local s=F.engine.db.settings;self.nudge:ClearAllPoints()
 if tonumber(s.bannerX) and tonumber(s.bannerY) then self.nudge:SetPoint("CENTER",UIParent,"CENTER",s.bannerX,s.bannerY)
 else self.nudge:SetPoint("TOP",UIParent,"TOP",0,-45) end
end
function U:SaveBannerPosition()
 self.nudge:StopMovingOrSizing()
 local x,y=self.nudge:GetCenter();local px,py=UIParent:GetCenter()
 local ratio=self.nudge:GetEffectiveScale()/UIParent:GetEffectiveScale()
 local s=F.engine.db.settings;s.bannerX=x*ratio-px;s.bannerY=y*ratio-py
 self:PositionBanner()
end
function U:FinishBannerMove()
 self.nudge:StopMovingOrSizing();self.movingBanner=nil;self.nudge:Hide();F.shown=nil;F.Draw()
 if self.settings then self.settings:Show() end
end
function U:MoveBanner()
 self:HideReminders();self.movingBanner=true
 if self.settings then self.settings:Hide() end
 self.nudgeTitle:SetText("Перетащи уведомление")
 self.nudgeBody:SetText("Положение сохраняется после перетаскивания")
 self.nudgeHeader:SetText("FitForever • настройка положения")
 self.nudgeStartText:SetText("Готово");self.nudgeLaterText:SetText("Закрыть")
 self:SetBannerIcon({id="stretch"});self:PositionBanner();self:RevealBanner()
end
function U:ResetBanner()
 F.engine.db.settings.bannerX=nil;F.engine.db.settings.bannerY=nil;self:PositionBanner()
end
function U:SetBannerIcon(r)
 if r.id=="stretch" then
  local path,paired=F.ShoulderTexture(1);self.nudgeIcon:SetTexture(path)
  self.nudgeIcon:SetTexCoord(paired and .22 or 0,paired and .78 or 1,0,paired and .56 or 1)
 else self.nudgeIcon:SetTexture(F.defs[r.id].icon);self.nudgeIcon:SetTexCoord(.08,.92,.08,.92) end
end

function U:Build()
 local s=F.engine.db.settings
 self.launch=CreateFrame("Button","FitForeverButton",Minimap,"BackdropTemplate")
 local b=self.launch; b:SetSize(30,30); b:SetPoint("TOPRIGHT",Minimap,"BOTTOMRIGHT",0,-5)
 b:SetNormalTexture("Interface\\Icons\\Spell_Nature_Rejuvenation"); b:RegisterForClicks("LeftButtonUp","RightButtonUp")
 b:SetScript("OnClick",function(_,which) if which=="RightButton" then U:Settings() else F.OpenPending() end end)
 b:SetScript("OnEnter",function(self)
  GameTooltip:SetOwner(self,"ANCHOR_LEFT"); GameTooltip:SetText("FitForever")
  GameTooltip:AddLine(F.Translate(F.Status()),.85,.9,.8,true)
  GameTooltip:AddLine(F.Translate("ЛКМ: напоминание / настройки\nПКМ: настройки"),.8,.8,.8,true); GameTooltip:Show()
 end)
 b:SetScript("OnLeave",function() GameTooltip:Hide() end)
 self.badge=text(b,16,20,2,20); self.badge:SetText("•"); self.badge:SetTextColor(1,.75,.3); self.badge:Hide()
 self.nudge=CreateFrame("Frame","FitForeverNudge",UIParent)
 self.nudge:SetSize(440,122);self.nudge:SetFrameStrata("DIALOG");self.nudge:SetClampedToScreen(true)
 self.nudge:EnableMouse(true);self.nudge:SetMovable(true);self.nudge:RegisterForDrag("LeftButton")
 rounded(self.nudge,440,122,18,{.13,.14,.13,.94})
 self.nudge:SetScript("OnDragStart",function(frame) if U.movingBanner then frame:StartMoving() end end)
 self.nudge:SetScript("OnDragStop",function() if U.movingBanner then U:SaveBannerPosition() end end)
 self.nudgeIcon=self.nudge:CreateTexture(nil,"ARTWORK");self.nudgeIcon:SetSize(60,60);self.nudgeIcon:SetPoint("TOPLEFT",14,-30)
 if self.nudge.CreateMaskTexture and self.nudgeIcon.AddMaskTexture then
  local mask=self.nudge:CreateMaskTexture(nil,"ARTWORK");mask:SetAllPoints(self.nudgeIcon)
  mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask","CLAMPTOBLACKADDITIVE","CLAMPTOBLACKADDITIVE")
  self.nudgeIcon:AddMaskTexture(mask);self.nudgeMask=mask
 end
 self.nudgeHeader=text(self.nudge,11,86,-12,304);self.nudgeHeader:SetTextColor(.72,.74,.70)
 self.nudgeTitle=text(self.nudge,18,86,-33,318)
 self.nudgeBody=text(self.nudge,12,86,-59,326)
 self.nudgeStart,self.nudgeStartText=pill(self.nudge,"Начать",86,-86,112,{.30,.46,.24,1},function()
  if U.movingBanner then U:FinishBannerMove() else F.Expand() end
 end)
 self.nudgeLater,self.nudgeLaterText=pill(self.nudge,"Позже",207,-86,96,{.25,.26,.25,1},function()
  if U.movingBanner then U:FinishBannerMove() else F.Resolve("later") end
 end)
 local close=CreateFrame("Button",nil,self.nudge);close:SetSize(25,25);close:SetPoint("TOPRIGHT",-8,-7)
 text(close,18,0,-2,25):SetText("×")
 close:SetScript("OnClick",function() if U.movingBanner then U:FinishBannerMove() else F.Tuck() end end)
 self:BuildBannerMotion();self:PositionBanner();self.nudge:Hide()
 self.flightShade=CreateFrame("Frame",nil,UIParent)
 self.flightShade:SetAllPoints(UIParent);self.flightShade:SetFrameStrata("DIALOG")
 local shade=self.flightShade:CreateTexture(nil,"BACKGROUND");shade:SetAllPoints();shade:SetColorTexture(0,0,0,.72)
 self.flightShade:EnableMouse(false);self.flightShade:Hide()
 self.card=box("FitForeverCard",520,640)
 self.cardTitle=text(self.card,21,22,-22,455)
 self.progress=text(self.card,13,22,-55,465)
 self.art=self.card:CreateTexture(nil,"ARTWORK"); self.art:SetPoint("TOPLEFT",20,-83); self.art:SetSize(480,250)
 self.dose=text(self.card,18,22,-348,470); self.dose:SetTextColor(unpack(green))
 self.body=text(self.card,15,22,-381,470); self.body:SetSpacing(4)
 self.source=text(self.card,11,22,-478,470)
 self.clock=text(self.card,13,22,-535,470)
 self.bar=CreateFrame("StatusBar",nil,self.card); self.bar:SetSize(470,16);self.bar:SetPoint("TOPLEFT",22,-511)
 self.bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8");self.bar:SetStatusBarColor(.46,.72,.53)
 self.bar:SetMinMaxValues(0,1)
 local bg=self.bar:CreateTexture(nil,"BACKGROUND");bg:SetAllPoints();bg:SetColorTexture(.16,.19,.16,1)
 self.start=button(self.card,"Начать",22,-567,145,function() F.StartActivity() end)
 button(self.card,"Готово",22,-601,145,function() F.DoneStep() end)
 button(self.card,"Пропустить",186,-601,145,function() F.SkipStep() end)
 button(self.card,"Позже",350,-601,145,function() F.Resolve("later") end)
 button(self.card,"×",475,-17,27,function() F.Tuck() end)
 self.card:SetScript("OnDragStop",function(frame)
  frame:StopMovingOrSizing()
  local x,y=frame:GetCenter(); local px,py=UIParent:GetCenter()
  local ratio=UIParent:GetEffectiveScale()/frame:GetEffectiveScale()
  s.cardX=x-px*ratio; s.cardY=y-py*ratio
  frame:ClearAllPoints(); frame:SetPoint("CENTER",UIParent,"CENTER",s.cardX,s.cardY)
 end)
 if tonumber(s.cardX) and tonumber(s.cardY) then self.card:ClearAllPoints(); self.card:SetPoint("CENTER",UIParent,"CENTER",s.cardX,s.cardY) end
 self:Scale()
end
function U:Scale()
 local v=F.engine.db.settings.scale
 local fit=math.min(v,(UIParent:GetHeight()-40)/880)
 self.card:SetScale(fit); self.nudge:SetScale(v)
 if self.settings then self.settings:SetScale(fit) end
end
function U:FlightMode(enabled)
 if enabled then
  if not self.flightLayout then
   self.flightLayout={self.card:GetPoint()}
   self.flightScale=self.card:GetScale()
  end
  self.card:ClearAllPoints();self.card:SetPoint("CENTER",UIParent,"CENTER",0,0)
  self.card:SetScale(self.flightScale)
  self.flightShade:Show()
 elseif self.flightLayout then
  self.card:ClearAllPoints();self.card:SetPoint(unpack(self.flightLayout));self.card:SetScale(self.flightScale)
  self.flightLayout=nil;self.flightScale=nil;self.flightShade:Hide()
 else self.flightShade:Hide() end
end
function U:HideReminders(animate) self.card:Hide(); self:HideBanner(animate);self:FlightMode(false) end
function U:ShowNudge(r)
 if F.InCompetitivePvP()~=false then self:HideReminders();return end
 self.card:Hide();self:FlightMode(false)
 self.nudgeHeader:SetText("FitForever"..(r.test and " • тест" or r.camp and " • у костра" or " • сейчас"))
 local titles={stretch="Пора размяться",eyes="Дай глазам отдохнуть",rest="Пора немного пройтись",water="Пауза для воды",meal="Время поесть",snack="Не проголодался?"}
 local details={stretch="Встань и немного подвигайся • в удобном темпе",eyes="Посмотри вдаль • 20 секунд",rest="Смени положение • 5–10 минут",water="Можно попить, если хочется",meal="Пауза на еду по твоему расписанию",snack="Перекус, если хочется есть"}
 self.nudgeTitle:SetText(r.contextTitle or titles[r.id]);self.nudgeBody:SetText(r.contextBody or details[r.id])
 self.nudgeStartText:SetText("Начать");self.nudgeLaterText:SetText("Позже")
 if r.notice then self.nudgeStartText:SetText("Вернулся");self.nudgeLaterText:SetText("Закрыть") end
 self:SetBannerIcon(r);self:PositionBanner();self:RevealBanner()
end
function U:TestBanner()
 F.Test("stretch");local r=F.testQueue[1];r.mode=nil;r.nudgedAt=nil
 self:HideReminders();F.shown=nil;F.Draw()
end
function U:ShowCard(r)
 if F.InCompetitivePvP()~=false then self:HideReminders();return end
 local d=F.defs[r.id]; local ex=r.routine and r.routine[r.step]
 self:FlightMode(r.flight==true)
 self:HideBanner(false); self.cardTitle:SetText((r.test and "ТЕСТ • " or "")..(r.contextTitle or (ex and ex.title or d.title)))
 self.progress:SetText(ex and ("Упражнение "..r.step.." из "..#r.routine) or "Пауза в удобном темпе")
 self.art:SetTexCoord(0,1,0,1)
 if ex then
  self.art:ClearAllPoints()
  if ex.id=="shoulders" or ex.id=="hands" or ex.id=="neck" then
   local path,paired=F.ExerciseTexture(ex.id,1);self.art:SetTexture(path)
   self.art:SetSize(paired and 250 or 480,250);self.art:SetPoint("TOP",0,-83)
  else
   self.art:SetTexture("Interface\\AddOns\\FitForever\\Media\\"..ex.art..".tga")
   self.art:SetSize(480,250);self.art:SetPoint("TOPLEFT",20,-83)
  end
 else
  self.art:SetTexture(d.icon);self.art:SetSize(112,112);self.art:ClearAllPoints();self.art:SetPoint("TOP",0,-142)
 end
 self.dose:SetText(ex and ex.dose or (r.id=="eyes" and "20 секунд вдали от экрана" or r.id=="rest" and "5–10 минут вне игры" or "Без обязательной нормы"))
 self.body:SetText(r.contextBody or (ex and ex.text or d.body))
 self.source:SetText(ex and (ex.source.."\nМягко, без боли. Можно пропустить.") or (r.test and "Тест не меняет реальные таймеры." or "Ты выбираешь, когда сделать паузу."))
 self:UpdateClock(r); self.card:Show()
end
function U:UpdateClock(r)
 local kind,total,ex=F.Activity(r)
 local elapsed=math.min(total,r.elapsed or 0)
 local value=kind=="timed" and elapsed or kind=="count" and (r.count or 0) or 0
 self.bar:SetMinMaxValues(0,total);self.bar:SetValue(value)
 self.start:SetShown(kind~="confirm")
 if kind=="timed" then
  self.start:SetText(r.started and "Пауза" or elapsed>=total and "Повторить" or elapsed>0 and "Продолжить" or "Начать")
  local left=math.max(0,total-elapsed)
  local label=elapsed>=total and "Время прошло. Подтверди, когда закончишь." or "Осталось: "..F.Clock(left)
  if not r.started and elapsed==0 then label="Нажми «Начать», когда будешь готов." end
  if ex and (ex.id=="shoulders" or ex.id=="hands" or ex.id=="neck") then
   local phase=F.ExerciseFrame(r);local path=F.ExerciseTexture(ex.id,phase);self.art:SetTexture(path)
   if r.started then
    if ex.id=="shoulders" then label=(phase==2 and "Удерживай плечи" or "Расслабь плечи").." • повтор "..math.min(3,math.floor(elapsed/5)+1).." из 3"
    elseif ex.id=="hands" then label=(phase==2 and "Раскрой ладони, расправь пальцы" or "Мягко собери кисти в кулаки").." • повтор "..math.min(3,math.floor(elapsed/4)+1).." из 3"
    else label=(phase==2 and "Поворот влево — без усилия" or phase==3 and "Поворот вправо — без усилия" or "Верни голову прямо").." • круг "..math.min(3,math.floor(elapsed/14)+1).." из 3" end
   end
  end
  self.clock:SetText(label)
 elseif kind=="count" then
  self.start:SetText("+1 повтор"); self.clock:SetText("Повторы: "..(r.count or 0).." из "..total.." • отмечай вручную")
 else self.clock:SetText("Прогресс: ожидает твоего подтверждения") end
 if r.opportunityUntil then self.progress:SetText((r.flight and "До посадки примерно " or "До конца перерыва ")..F.Clock(math.max(0,r.opportunityUntil-GetTime())))
 elseif r.flight then self.progress:SetText("Время полёта неизвестно • короткая разминка")
 elseif r.camp and r.campUntil then
  self.progress:SetText("У костра осталось "..F.Clock(math.max(0,r.campUntil-GetTime())).." • удобный момент для паузы")
 end
end
function U:Settings()
 if self.settings then self.settings:Show(); self:RefreshSettings(); return end
 local p=box("FitForeverSettings",670,870); self.settings=p; p:SetFrameStrata("DIALOG")
 text(p,23,22,-20):SetText("FitForever")
 text(p,13,22,-54,620):SetText("Тихие паузы • "..F.version.." • перетащи окно за свободное место")
 button(p,"×",620,-17,27,function() p:Hide() end)
 self.rows={}
 for i,id in ipairs(F.order) do
  local key=id; local d=F.defs[key]; local y=-90-(i-1)*53
  local c=check(p,d.title,20,y,F.engine.db.settings.modules[key].enabled,function(v) F.SetModule(key,v) end)
  local e
  if d.minutes then
   e=edit(p,F.engine.db.settings.modules[key].minutes,294,y,55)
   text(p,12,355,y-7,40):SetText("мин")
   local function apply(self)
    local v=tonumber(self:GetText()); if not v or v<5 or v>240 then self:SetText(F.engine.db.settings.modules[key].minutes); F.Message("Интервал: от 5 до 240 минут."); return end
    F.SetModule(key,nil,math.floor(v)); self:ClearFocus()
   end
   e:SetScript("OnEnterPressed",apply); e:SetScript("OnEditFocusLost",function(self)
    local v=tonumber(self:GetText()); if v and v>=5 and v<=240 and math.floor(v)~=F.engine.db.settings.modules[key].minutes then F.SetModule(key,nil,math.floor(v)) end
    self:SetText(F.engine.db.settings.modules[key].minutes)
   end)
  end
  button(p,"Тест",414,y,78,function() F.Test(key) end)
  local status=text(p,11,52,y-29,340)
  self.rows[key]={check=c,edit=e,status=status}
 end
 text(p,12,24,-416,230):SetText("Еда, местное время (до 6 точек):")
 self.meals=edit(p,F.engine.db.settings.mealTimes,265,-410,245)
 button(p,"Сохранить",526,-410,118,function()
  local value=U.meals:GetText(); if F.Engine.ParseMeals(value) then F.engine.db.settings.mealTimes=value; U.meals:ClearFocus(); F.Message("Расписание еды сохранено.") else F.Message("Формат: 09:00, 13:00, 19:00") end
 end)
 self.afk=check(p,"Не считать время AFK",20,-452,F.engine.db.settings.excludeAFK,function(v) F.engine.db.settings.excludeAFK=v end)
 self.sound=check(p,"Звук напоминаний",345,-452,F.engine.db.settings.sound,function(v) F.engine.db.settings.sound=v end)
 button(p,"Упражнения / тесты",22,-496,195,function() U:Exercises() end)
 button(p,"Тест очереди",229,-496,130,function() F.TestQueue() end)
 button(p,"Тест боя (8 с)",370,-496,140,function() F.TestCombat() end)
 self.pause=button(p,"Пауза",521,-496,125,function() F.TogglePause(); U:RefreshSettings() end)
 button(p,"Меньше",22,-537,90,function() F.engine.db.settings.scale=math.max(.7,F.engine.db.settings.scale-.1); U:Scale() end)
 button(p,"Больше",122,-537,90,function() F.engine.db.settings.scale=math.min(1.3,F.engine.db.settings.scale+.1); U:Scale() end)
 text(p,12,231,-542,400):SetText("«Позже» = 5 минут. Закрытие окна не означает «выполнено».")
 self.finishSound=check(p,"Звук окончания",20,-578,F.engine.db.settings.finishSound,function(v) F.engine.db.settings.finishSound=v end)
 button(p,"Тест звука",345,-578,130,function() F.FinishSignal({}) end)
 button(p,"Сессия / таймеры",490,-578,150,function() U:SessionSettings() end)
 self.campfire=check(p,"Предложение у костра",20,-614,F.engine.db.settings.campfire,function(v) F.engine.db.settings.campfire=v end)
 button(p,"Тест костра",345,-614,130,function() F.TestCamp() end)
 self.flights=check(p,"Карточка в полёте",20,-650,F.engine.db.settings.flights,function(v) F.engine.db.settings.flights=v end)
 button(p,"Тест перелёта",345,-650,130,function() F.TestFlight() end)
 button(p,"Перерывы",490,-650,150,function() U:OpportunitiesSettings() end)
 button(p,"Переместить баннер",22,-688,195,function() U:MoveBanner() end)
 button(p,"Сбросить позицию",229,-688,180,function() U:ResetBanner() end)
 button(p,"Тест баннера",421,-688,180,function() U:TestBanner() end)
 text(p,13,22,-730,130):SetText("Язык / Language")
 self.languages={}
 for _,entry in ipairs({{'auto','Авто (клиент)',155},{'ruRU','Русский',340},{'enUS','English',490}}) do
  local choice,label,x=unpack(entry)
  self.languages[choice]=check(p,label,x,-723,F.engine.db.settings.language==choice,function() F.SetLanguage(choice) end)
 end
 local race,gender,faction,label=F.Identity()
 local _,paired=F.ShoulderTexture(1)
 text(p,11,22,-782,624):SetText("Рисунок плеч: "..(label or race or "не определён").." • "..(gender=="female" and "женский" or gender=="male" and "мужской" or "—").." • "..(paired and "два кадра" or "общий рисунок"))
 text(p,11,22,-814,624):SetText("Интервалы воды и перекуса — настройки напоминаний, не нормы питания.\nEnter применяет интервал. Подробности и источники: README.md в папке аддона.")
 self:Scale(); self:RefreshSettings(); p:Show()
end
function U:RefreshSettings()
 if not self.rows then return end
 for id,r in pairs(self.rows) do
  local m=F.engine.db.settings.modules[id]; r.check:SetChecked(m.enabled)
  r.status:SetText(not m.enabled and "Выключено" or id=="meal" and "По твоему расписанию" or ("До напоминания: "..F.Clock(F.engine.db.remaining[id] or 0)))
 end
 self.pause:SetText(F.engine.paused and "Продолжить" or "Пауза")
 if self.languages then for choice,widget in pairs(self.languages) do widget:SetChecked(F.engine.db.settings.language==choice) end end
end
function U:Exercises()
 if self.settings then self.settings:Hide() end
 if self.library then self.library:Show(); return end
 local p=box("FitForeverExercises",490,375); self.library=p
 text(p,20,20,-20):SetText("Рисунки и упражнения")
 button(p,"×",445,-15,28,function() p:Hide();U:Settings() end)
 for i,ex in ipairs(F.exercises) do
  local item=ex; local y=-67-(i-1)*64
  text(p,14,20,y,310):SetText(item.title)
  text(p,11,20,y-22,330):SetText(item.dose)
  button(p,"Тест",370,y,90,function() F.Test("stretch",item) end)
 end
 text(p,12,20,-333,450):SetText("В разминке — 2 упражнения. Недавние выполняются реже.")
 p:SetScale(self.card:GetScale()); p:Show()
end

function U:OpportunitiesSettings()
 if self.opportunities then self.opportunities:Show();return end
 local p=box("FitForeverOpportunities",540,330);self.opportunities=p
 text(p,20,20,-20):SetText("Полёты и рейдовые перерывы")
 button(p,"×",495,-15,28,function() p:Hide() end)
 check(p,"Сигнал за минуту до возвращения",20,-65,F.engine.db.settings.returnSound,function(v) F.engine.db.settings.returnSound=v end)
 button(p,"Тест сигнала",365,-65,150,function() p:Hide();F.TestOpportunity('signal') end)
 check(p,"Объявления перерыва в рейде",20,-105,F.engine.db.settings.raidBreaks,function(v) F.engine.db.settings.raidBreaks=v end)
 button(p,"Тест перерыва",365,-105,150,function() p:Hide();F.TestOpportunity('raid') end)
 button(p,"Тест длинного полёта",20,-150,240,function() p:Hide();F.TestOpportunity('long') end)
 button(p,"Тест короткого полёта",275,-150,240,function() p:Hide();F.TestFlight() end)
 text(p,12,20,-204,500):SetText("Время полёта берётся из обратного отсчёта Travelcraft.\nЕсли оно неизвестно, предлагаются короткие упражнения.\nПерерыв: «Перерыв 5 минут» или «break 5 min» от лидера\nили помощника. «Перерыв окончен» отменяет предложение.\nВода и еда предлагаются только по включённым напоминаниям.")
 p:SetScale(self.card:GetScale());p:Show()
end

function U:SessionSettings()
 if self.settings then self.settings:Hide() end
 if self.sessionSettings then self.sessionSettings:Show();return end
 local p=box('FitForeverSessionSettings',620,430);self.sessionSettings=p
 text(p,20,22,-20,550):SetText('Сессия и интервалы')
 button(p,'×',575,-15,28,function() p:Hide();U:Settings() end)
 text(p,13,22,-65,570):SetText('Новый вход — новая сессия для всех напоминаний.\n/reload и переходы между зонами сохраняют отсчёт.')
 text(p,13,22,-120,570):SetText('Глаза: каждые 20 минут, смотреть вдаль 20 секунд.\nДвижение: каждые 30 минут, встать и сменить позу.\nПерерыв: каждый час, 5–10 минут вне экрана.')
 text(p,12,22,-195,570):SetText('Вода и перекусы: общего медицинского интервала нет.\nИх частоту выбираешь сам; еда — по твоему расписанию.\nПосле входа пропущенные часы еды не догоняются.')
 button(p,'Тест новой сессии',22,-270,260,function() F.TestSession() end)
 button(p,'Базовые интервалы',305,-270,290,function() F.RecommendedIntervals() end)
 text(p,12,22,-315,570):SetText('«Базовые интервалы» устанавливает 20 / 30 / 60 минут\nдля глаз, разминки и прогулки и запускает их заново.\nСидячие упражнения не заменяют вставание и движение.\nИсточники: AOA, NHS, HSE. Подробности — в README.')
 button(p,'Тест БГ (8 с)',22,-390,260,function() p:Hide();F.TestPvP() end)
 p:SetScale(self.card:GetScale());p:Show()
end
