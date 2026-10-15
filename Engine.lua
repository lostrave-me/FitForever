local _, F = ...
local E = {}; F.Engine = E
local function copy(t)
 local out={}; for k,v in pairs(t) do out[k]=type(v)=="table" and copy(v) or v end; return out
end
F.Copy = copy
function E.New(saved, now)
 local db=type(saved)=="table" and saved or {}
 db.version=1; db.settings=type(db.settings)=="table" and db.settings or {}
 local s=db.settings
 if s.language~='ruRU' and s.language~='enUS' then s.language='auto' end
 if s.excludeAFK==nil then s.excludeAFK=true end
 if s.sound==nil then s.sound=false end
 if s.finishSound==nil then s.finishSound=true end
 if s.campfire==nil then s.campfire=true end
 if s.flights==nil then s.flights=true end
 if s.returnSound==nil then s.returnSound=true end
 if s.raidBreaks==nil then s.raidBreaks=true end
 s.scale=math.max(.7,math.min(1.3,tonumber(s.scale) or 1))
 s.snooze=math.max(1,math.min(60,tonumber(s.snooze) or 5))
 s.mealTimes=type(s.mealTimes)=="string" and s.mealTimes or "09:00, 13:00, 19:00"
 s.modules=type(s.modules)=="table" and s.modules or {}
 db.remaining=type(db.remaining)=="table" and db.remaining or {}
 db.recent=type(db.recent)=="table" and db.recent or {}
 db.meals=type(db.meals)=="table" and db.meals or {}
 db.snoozes=type(db.snoozes)=="table" and db.snoozes or {}
 for _,id in ipairs(F.order) do
  local d=F.defs[id]; local m=s.modules[id]
  if type(m)~="table" then m={}; s.modules[id]=m end
  if m.enabled==nil then m.enabled=d.enabled end
  if d.minutes then
   m.minutes=math.max(5,math.min(240,tonumber(m.minutes) or d.minutes))
   db.remaining[id]=math.max(0,math.min(m.minutes*60,tonumber(db.remaining[id]) or m.minutes*60))
  end
 end
 db.lastSeen=now
 return setmetatable({db=db,session=math.max(0,tonumber(db.sessionSeconds) or 0),paused=false,queue={},current=nil},{__index=E})
end
-- A real character login starts a new session. Reloading only reconstructs state.
function E:BeginSession(now,day,minute)
 self.queue={};self.current=nil;self.session=0;self.paused=false
 self.db.sessionSeconds=0;self.db.sessionStartedAt=now;self.db.lastSeen=now
 self.db.snoozes={}
 self.db.mealSession={day=day,minute=minute}
 for _,id in ipairs(F.order) do
  local m=self.db.settings.modules[id]
  if m.minutes then self.db.remaining[id]=m.minutes*60 end
 end
end
function E:RecommendedIntervals()
 for _,id in ipairs({'eyes','stretch','rest'}) do
  self.db.settings.modules[id].minutes=F.defs[id].minutes
  self:Reset(id)
  if self.current and self.current.id==id then self.current=nil end
 end
end
function E.ParseMeals(text)
 local list={}; local seen={}
 for token in (text..","):gmatch("(.-),") do
  token=token:match("^%s*(.-)%s*$")
  if token~="" then
   local h,m=token:match("^(%d%d?):(%d%d)$"); h,m=tonumber(h),tonumber(m)
   if not h or h>23 or m>59 then return nil end
   local n=h*60+m; if not seen[n] then list[#list+1]=n; seen[n]=true end
  end
 end
 if #list==0 or #list>6 then return nil end
 table.sort(list); return list
end
function E:Has(id)
 if self.current and self.current.id==id then return true end
 for _,r in ipairs(self.queue) do if r.id==id then return true end end
end
function E:Add(id,mealKey)
 if not self:Has(id) then self.queue[#self.queue+1]={id=id,mealKey=mealKey,snoozeUntil=tonumber(self.db.snoozes[id])} end
end
function E:Tick(delta,now,afk,day,minute)
 self.db.lastSeen=now
 if self.paused then return end
 delta=math.max(0,math.min(delta,60))
 if not (afk and self.db.settings.excludeAFK) then
  self.session=self.session+delta;self.db.sessionSeconds=self.session
  for _,id in ipairs(F.order) do
   local m=self.db.settings.modules[id]
   if m.enabled and m.minutes then
    self.db.remaining[id]=math.max(0,self.db.remaining[id]-delta)
    if self.db.remaining[id]==0 then self:Add(id) end
   end
  end
 end
 if self.db.settings.modules.meal.enabled then
  for _,n in ipairs(E.ParseMeals(self.db.settings.mealTimes) or {}) do
   local key=day..":"..n
   local start=self.db.mealSession
   local afterStart=type(start)~='table' or start.day~=day or n>(tonumber(start.minute) or -1)
   if afterStart and minute>=n and minute<n+60 and not self.db.meals[key] then self:Add("meal",key) end
  end
 end
 -- Keep the meal deduplication table bounded without altering today's marks.
 for k in pairs(self.db.meals) do if k:sub(1,#day)~=day then self.db.meals[k]=nil end end
end
function E:Next()
 if self.current then return self.current end
 for _,id in ipairs(F.order) do
  for i,r in ipairs(self.queue) do
   if r.id==id then self.current=table.remove(self.queue,i); return self.current end
  end
 end
end
function E:Reset(id)
 self.db.snoozes[id]=nil
 local m=self.db.settings.modules[id]
 if m.minutes then self.db.remaining[id]=m.minutes*60 end
 for i=#self.queue,1,-1 do if self.queue[i].id==id then table.remove(self.queue,i) end end
end
function E:Resolve(action,now)
 local r=self.current; if not r then return end
 if action=="later" then
  r.snoozeUntil=now+self.db.settings.snooze*60
  self.db.snoozes[r.id]=r.snoozeUntil
  self.queue[#self.queue+1]=r
 elseif r.id=="meal" then self.db.meals[r.mealKey or "test"]=true; self.db.snoozes.meal=nil
 else
  self:Reset(r.id)
  if r.id=="rest" then self:Reset("stretch"); self:Reset("eyes") end
 end
 self.current=nil
end
function E:Ready(now)
 if self.current then return self.current end
 for _,id in ipairs(F.order) do
  for i,r in ipairs(self.queue) do
   if r.id==id and (not r.snoozeUntil or now>=r.snoozeUntil) then
    self.current=table.remove(self.queue,i); return self.current
   end
  end
 end
end
function E:SetModule(id,enabled,minutes)
 local m=self.db.settings.modules[id]; m.enabled=enabled
 if minutes then m.minutes=minutes; self:Reset(id) end
 if not enabled then
  self.db.snoozes[id]=nil
  for i=#self.queue,1,-1 do if self.queue[i].id==id then table.remove(self.queue,i) end end
  if self.current and self.current.id==id then self.current=nil end
 end
end
function E:Routine()
 local list={}; for i,x in ipairs(F.exercises) do list[#list+1]={x=x,i=i,used=tonumber(self.db.recent[x.id]) or 0} end
 table.sort(list,function(a,b) if a.used==b.used then return a.i<b.i end return a.used<b.used end)
 return {list[1].x,list[2].x}
end
