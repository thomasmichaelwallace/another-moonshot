pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--another moonshot
--@thomasmichaelwallace

--flags:
--0:blocks char
--   unless 4,4 is trans and map
--    has colour changer.
--   blocks looker sight unless
--    is in lk.t
--1:can be talked to
--   looks up tx[v] for dia.
--2:can host/is placeable
--   (+1) is host else placable
--3:can be pushed/pushed on
--   (+1) is pushable else on.
--4:can be cut
--5:can be collected
--6:is colour changer
--7:is swing hook

function _init()
 --ok:_init_tit()
end

function _update60()
 if(tl.v)then
  _update_tit()
 elseif(fd.m)then
  _update_end()
 else
	 _update_map()
	 if(dg.v)then
	  _update_dia()
	 else
	  _update_res()
	  _update_lok()
	  _update_fig()
	  _update_cut()
	  _update_swg()
	 end
	end
end

function _draw()
 cls()
 if(tl.v)then
  _draw_tit()
 elseif(fd.m)then
  _draw_end()
 else
	 _draw_map()
	 _draw_lok()
	 _draw_fig()
	 _draw_dia()
	 _draw_cut()
	end
end
-->8
--map system

mp={--map state
 n=10,--map no.
 x=0,--screen top-left x
 y=0,-- /y
 s={--scroll
  t=false,--scrolling
  n=0,--next map no.
  d=0,--direciton 0⬅️➡️⬆️⬇️3
  x=0,--n/map s/top-left x
  y=0,-- /y
 },
 a={--animations
  t=0,--tick
  f=0,--frame no.
  b=false,--blit.
 },
 m=-1,--current music
 t={--music map
   3, 3, 9,11,11, 2, 2, 9,
   5, 2, 2, 7, 7, 2, 2, 5,
 }
}

--n:sprite tile no
--sx/y:screen x/y
function mapn(n,sx,sy)
 if(rb.c~=nil)then
  --only affected
  if(n==8 or n==15 or n==4)palt(rb.c,true)
 end
 local y=0
 if(n>7)then
  y=16
  n-=8
 end
 local x=16*n 
 map(x,y,sx,sy,16,16)
 --blit animation
 if(mp.a.b)then
  for ax=x,x+16,1 do
   for ay=y,y+16,1 do
    local m=mget(ax,ay)
    if(m>=128 and m<=191)then
     if(m%2==1)then
      mset(ax,ay,m-1)
     else
      mset(ax,ay,m+1)
     end
    end
   end
  end
  mp.a.b=false
 end
 if(rb.c~=nil)palt(rb.c,false)
end

function scroll_map()
 local s=8--speed
 if(mp.s.t)then
  if(mp.s.d==1)then
   mp.x-=s
   mp.s.x-=s
   fg.x-=s
   if(mp.s.x<=0)mp.s.t=false
  elseif(mp.s.d==0)then
   mp.x+=s
   mp.s.x+=s
   fg.x+=s
   if(mp.s.x>=0)mp.s.t=false
  elseif(mp.s.d==3)then
   mp.y-=s
   mp.s.y-=s
   fg.y-=s
   if(mp.s.y<=0)mp.s.t=false
  elseif(mp.s.d==2)then
   mp.y+=s
   mp.s.y+=s
   fg.y+=s
   if(mp.s.y>=0)mp.s.t=false
  end
  if(mp.s.t==false)then
   mp.x=0
   mp.y=0
   mp.n=mp.s.n
   mp.s.x=0
   mp.s.y=0
  end
 end
end

--d:scroll direction 0⬅️➡️⬆️⬇️3
function move_map(d)
 local n=mp.n
 if(d==0)then--⬅️
  if(n==0)return
  if(n>4 and n<=8)return
  if(n>12)return
  mp.s.n=n-1
  mp.s.x=-128
 elseif(d==1)then--➡️
  if(n>=4 and n<8)return
  if(n>=12)return
  mp.s.n=n+1
  mp.s.x=128
 elseif(d==2)then--⬆️
  if(n==15)n=16
  if(n==6)n=18
  if(n<=1)return
  if(n==2)n=15
  if(n==3)return
  if(n==4)n=21
  if(n==7 or n==5)return
  mp.s.n=n-8
  mp.s.y=-128
 elseif(d==3)then--⬇️
  if(n==7)n=-6
  if(n==13)n=-4
  if(n==8)n=7
  if(n==9)return
  if(n==10)n=-2
  if(n==11 or n==12)return
  if(n==15 or n==14)return
  mp.s.n=n+8  
  mp.s.y=128
 end
 --music
 local t=mp.t[mp.s.n+1]
 if(t==11 and not fd.o)t=2
 if(mp.m~=t)then
  mp.m=t
  music(t)
 end
 --start scroll
 mp.s.t=true
 mp.s.d=d
end

function mxyget(x,y)
 local mx,my=x/8,y/8
 local n=mp.n
 if(n>7)then
  n-=8
  my+=16
 end
 mx+=16*n
 my=min(31,my)
 return {mx=mx,my=my}
end

--x/y:screen x/y
function mgetp(x,y)
 local p=mxyget(x,y)
 return mget(p.mx,p.my)
end

--x/y:screen x/y
--v:map value
function msetp(x,y,v)
 local p=mxyget(x,y)
 --syncronise v with ani.
 if(v>=128 and v<=191)v+=mp.a.f
 return mset(p.mx,p.my,v)
end

function _update_map()
 --animations
 mp.a.t+=1
 if(mp.a.t==24)then--frames/second
  mp.a.t=0
  mp.a.f=(mp.a.f+1)%2
  mp.a.b=true
 end
 --scroll 
 if(mp.s.t)scroll_map()
end

function _draw_map()
 mapn(mp.n,mp.x,mp.y)
 if(mp.s.t)then
  mapn(mp.s.n,mp.s.x,mp.s.y)
 end
end
-->8
--dialogue system

dg={--dialogue state
 v=false,--show
 n="name",--name
 t="text.",--text
 s=64,--t/l sprite no.
 i=1,--selected index
 c=7,--text color
 h=6,--highlight colour
 o={{--dia.options list
  t="ok",--text
  f=function()end,--selected fn.
 }}
}

ch={--character definitions
 {
 	s=64,--sprite
 	n="ol' blue",--name
 	c=12,--highlight colour
 },
 {s=66 ,c=14,n="doribone gray"},
 {s=68 ,c=14,n="pinky bryan"},
 {s=70 ,c=10,n="c-dog"},
 {s=96 ,c= 9,n="cap'n tango"},
 {s=98 ,c= 8,n="baba junior"},
 {s=100,c=12,n="baba seniors"},
 {s=102,c= 4,n="?"},
}

--n:t/l sprite no.
--w/h:width/height in sprites
--dx/dy:t/l screen position
--s:scale factor
function zspr(n,w,h,dx,dy,s)
 local sx,sy=(n%16)*8,(n\16)*8
 local sw,sh=8*w,8*h
 local dw,dh=sw*s,sh*s
 sspr(sx,sy,sw,sh,dx,dy,dw,dh)
end

--s:string
--lw:max pixel line width
function word_wrap(s,lw)
 local l={}--lines
 local b=""--buffer
 local w=0--line width
 local cl=""--current line
 local cw=0--current width
 local nl=false--new line
 
 for n=1,#s do
  nl=false
  local c=sub(s,n,n)
  if(ord(c)==32)then
   cl,cw=cl..b,w
   b=c
  elseif(ord(c)==10)then
   cl,cw=cl..b,w
   b=""
   nl=true
  else
   b=b..c
  end
  w+=4
  if(ord(c)>127)w+=4
  if(w>lw or nl)then
   if(#cl==0)then
    cl,cw=b,w
    w+=4
    b=" "
   end
   add(l,{t=cl,w=cw})
   cl=""
   b=sub(b,2)
   w-=(cw+4)
  end
 end
 cl=cl..b
 add(l,{t=cl,w=w})
 return l
end

--t:text
--x/y0/1:corners
--h/v:-101 l/c/r h/v align
--c:colour
function text_rect(t,x0,y0,x1,y1,h,v,c)
 local rw=abs(x0-x1)
 local rh=abs(y0-y1)
 local ox=min(x0,x1)
 local oy=min(y0,y1)
 local lns=word_wrap(t,rw)
 for n=1,#lns do
  local l=lns[n]
  local x=ox
  if(h==0)x+=flr((rw-l.w)/2)+1
  if(h==1)x+=(rw-l.w)+2
  if(v==-1)y=6*(n-1)
  if(v==0)y=flr((rh-6*#lns)/2)+6*(n-1)+1
  if(v==1)y=rh-(6*(#lns-n+1))+2
  y+=oy
  print(l.t,x,y,c)
 end
end

--i:tx data index/{cto}object
function show_dia(i)
 local t=i
 --lookup
 if(type(i)=="number")then
  --normalise farmers
  if(i>=243 and i<=246)i=243
  if(i>=247 and i<=250)i=247
  --normalise statues
  if(i==197)i=195
  --normalise console
  if(i==215 or i==216 or i==138 or i==139)i=215
  --support fns
  t=tx[i]
  if(type(t)~="table")t=t()
 end
 if(t==nil)return--short circut
 --apply
 dg.i=1
 dg.t=t.t
 dg.n=ch[t.c].n
 dg.h=ch[t.c].c
 dg.s=ch[t.c].s
 dg.o=t.o==nil and {tc.ok} or t.o
 dg.v=true
end

function try_dia()
 local c=fig_cast(4,1)
 if(c==nil)return false
 show_dia(c.m)
 return true
end

function _update_dia()
 if(not dg.v)return
 if(btnp(2)and dg.i>1)dg.i-=1
 if(btnp(3)and dg.i<#dg.o)dg.i+=1
 if(btnp(4)or btnp(5))then
  dg.v=false
  local f=dg.o[dg.i].f
  if(type(f)=="number")then
   show_dia(f)
  else
   f()
  end
 end
end

function _draw_dia()
 if(not dg.v)return
 --frame
 rectfill(11,11,117,117,0)
 rect(12,12,116,116,dg.h)
 rect(14,14,114,114,dg.h)
 --portrait and header
 zspr(dg.s,2,2,2,2,2)
 print(dg.n,36,24,dg.h)
 --body
 text_rect(dg.t,17,36,110,111,-1,-1,dg.c)
 --options
 print("\n")
 for i=1,#dg.o,1 do
  if(i==dg.i)then
   color(dg.h)
   print("웃"..dg.o[i].t)
  else
   color(dg.c)
   print("  "..dg.o[i].t)
  end
 end
end
-->8
--figure system

fg={--figure state
 x=80,y=104,--screen x/y 
 a={--animation sprites
	 --⬅️➡️⬆️⬇️
	 -- - still-move-flip?
	 {{193,209},{209,208},false},
	 {{193,209},{209,208}, true},
	 {{224,240},{194,210},false},
	 {{225,241},{226,242},false},
 },
 d=4,--direction no: 1⬅️➡️⬆️⬇️4
 m=false,--moving?
 t=0,--tick
 f=1,--animation frame no (1/2) 
}

--m:map tile no
--f:flag to check for
function fpget(m,f)
 local b=fget(m,f)
 if(not b)return false
 if(f>0)return true
 if(rb.c==nil)return true
 local x,y=(m%16)*8+4,(m\16)*8+4
 local c=sget(x,y)
 return c~=rb.c
end

--l:length in dir to check
--f:flag to check for
function fig_cast(l,f)
 --fig t/l
 local h=7--sprite height
 local w=6--/width
 --checkpoints 0,1
 local x0=fg.x+(8-w)/2
 local y0=fg.y+(8-h)
 local x1,y1=x0,y0 
 if(fg.d==1)then--⬅️
  x0-=l
  x1,y1=x0,y0+h-1--:웃
 elseif(fg.d==2)then--➡️
  x0+=w+l-1
  x1,y1=x0,y0+h-1--웃:
 elseif(fg.d==3)then--⬆️
  y0-=l          --..
  x1,y1=x0+w-1,y0--웃
 elseif(fg.d==4)then--⬇️
  y0+=h+l-1      --웃
  x1,y1=x0+w-1,y0--''
 end
 local m0,m1=mgetp(x0,y0),mgetp(x1,y1)
 local c=nil
 if(fpget(m0,f))then
  c={m=m0,x=x0,y=y0}
 elseif(fpget(m1,f))then
  c={m=m1,x=x1,y=y1}
 else
  return nil  
 end
 --normalise anis.
 if(c.m>=128 and c.m<=191)c.m-=c.m%2
 return c
end

function move_fig()
 local s=1--ok:1/3--speed
 local m=fig_cast(s,0)
 --workaround 7 south block
 if(mp.n==7 and fg.y>118 and fg.d==4)m=nil
 if(m)return false
 if(fg.d==1)fg.x-=s
 if(fg.d==2)fg.x+=s
 if(fg.d==3)fg.y-=s
 if(fg.d==4)fg.y+=s
 return true
end

function try_scroll()
 if(fg.x<-4)then
  move_map(0)
 elseif(fg.x>124)then
  move_map(1)
 elseif(fg.y<-4)then
  move_map(2)
 elseif(fg.y>124)then
  move_map(3)
 end
end

function _update_fig()
 if(mp.s.t)return--scrolling
 if(hk.s)then--swinging
  try_scroll()
  return
 end
 --control
 local m=true
 if(btn(0))then
  fg.d=1
 elseif(btn(1))then
  fg.d=2
 elseif(btn(2))then
  fg.d=3
 elseif(btn(3))then
  fg.d=4
 else
  m=false
 end
 --collide 
 if(m)then
  try_push()
  try_collect()
  m=move_fig()
 end
 --scroll
 try_scroll()
 --interact
 if(btnp(4)or btnp(5))then
  if(try_dia())then
   --sideeffects
  elseif(try_place())then
  elseif(try_col())then
  elseif(try_swing())then
  elseif(try_cut())then
  end
 end
 --ticker
 fg.t+=1
 if(m~=fg.m)then
  fg.m=m
  fg.t=0--restart
 end
 if(fg.t==24)then
  fg.t=0
  fg.f+=1
  if(fg.f==3)fg.f=1
 end 
end

function _draw_fig()
 local a=fg.a[fg.d]
 local m=fg.m and 2 or 1
 local s=a[m][fg.f]
 spr(s,fg.x,fg.y,1,1,a[3])
end
-->8
--text resources

tc={--text constants
 ok={t="ok",f=function()end},
 no={t="no",f=function()end},
 rs={t="no",f=function()
  do_reset()
 end}
}

ts={
 "thanks for bringing our village back together again, good luck on the moonshot!",
 "what a landing... that ship looks pretty busted; there's bits scatted throughout this village.",
 "i found one, but- would you help an old man see his wife one more time; i'm too old to walk to her monolith these days.",
 "it is to the east, you'll have to push it along path, press ❎ to pick up and put down logs.",
 "this used to be such a happy place; maybe you can make it so again as you pick up the pieces.",
 "thanks for bringing my wife to me, it's nice to have her close again. when you've got all the pieces, head north-east.",
 "wow. it's great to have her so close again. here's the piece of your ship.",
 "return the monolith back to where it started?",
 "thanks for cutting the grass; gives the village some respect.",
 "that falling debris scared away all the fish. i picked it up, but you owe me 20 coins. press ❎ to cut down long grass and find coinage.",
 "ok, that's 20, you can have your piece.",
 "wow, you found them all!",
 "seeing that trophy reminded me of how happy i was competing, i'm too old now- but maybe i can start helping others...",
 "this shard recked my store room, just save my gymnastics trophy and you can get it back",
 "press ❎ to swing on hooks. you might need to use your sword (❎) to dislodge the stuck hooks.",
 "wow, this brings back memories... you can have this back.",
 "so many memories...",
 "looks like the trophy. i should bring it back.",
 "ok- let's swap the spade for this hoe and bring that back...",
 "ok- let's take this hoe to swap it with the spade...",
 "ok, i'll put the hoe back for now.",
 "swap complete! and what's this- a piece of your ship!",
 "hey! you put my hoe back this instant!",
 "hey! you keep that spade away from my field!",
 "hmm- you know- this spade isn't all that bad...",
 "i love my hoe. won't touch a spade. unlike my brothers. if you can steal their spade it'll make my day.",
 "hey- thanks. together- hoe and spade, us brothers are making good on the land.",
 "ok - let's swap the hoe for this spade and bring that back...",
 "ok - let's take this spade and swap it with the hoe...",
 "ok, i'll put the spade back for now.",
 "swap complete! and what's this- a piece of your ship!",
 "oi! get back here with my spade!",
 "oi! get that hoe outta my field!",
 "hmm- you know- this hoe isn't all that bad...",
 "i love my spade. won't touch a hoe. unlike my brother. if you can steal their hoe it'd make our day.",
 "hey- thanks. together- hoe and spade, us brothers are making good on the land.",
 "thanks for bringing me and my son back together again.",
 "you delivered my message? thank you, i shouldn't have waited so long...",
 "hmm- nothing landed here, but maybe you can help me get through to my son and ask him?",
 "press ❎ to switch the color changers and clear the way",
 "we don't always see eye to eye, but he is my dad - thank you.",
 "my dad sent you? wow, it's been so long since he reached out...",
 "you can have this- i found it in the garden.",
 "ok- let's get back to the ship!",
 "it's time to go- for another moonshot."
}

tx={--text resources
 [0]={--sprite no.
  c=1,--ch index
  t="test",--text block
  o={{--options list
   t="ok",--text
   f=function()end--sel.function
  }}
 },
 
 --statue/old blue
 [176]=function()
  if(fd.o)then
   return{
    c=1,
    t=ts[1]--end game
   }
  end
  local t=ts[2] --what a landing
  local o={{t="the village?",f=176.1}}
  if(not pu.f)then
   o[2]={t="the pieces?!",f=176.2}
  else
   t=ts[6]--thanks for wife
  end
  o[#o+1]=tc.ok
  return {c=1,t=t,o=o}
 end,
 [176.1]={
  c=1,
  t=ts[5]--about village
 },
 [176.2]={
  c=1,
  t=ts[3],--start of statue expl.
  o={{t="...",f=176.21}}
 },
 [176.21]={
  c=1,
  t=ts[4]--end of statue expl.
 },
 [176.3]={
  c=1,
  t=ts[7]--statue into position
 },
 [195]=function()
  if(pu.f)return nil
  if(mp.n<11 or mp.n>12)return nil
  return {
   c=8,
   t=ts[8], --reset statue
   o={tc.no,{
    t="yes",
    f=function()
     do_reset()
    end,
   }}
  }
 end,
 
 --coin man
 [162]=function()
  if(fd.o)then
   return{
    c=4,
    t=ts[9],--"good bye from yellow."
   }
  end
  if(sw.n==0)then
   t=ts[10]--"get me coin"
  else
   t="nice try, but you've only got "..tostr(sw.n).." coins, i want 20"
  end
  if(sw.n>=20)then
   if(not sw.w)then
    t=ts[11]--you have piece now.
    sw.w=true
   elseif(sw.n>40)then
    t=ts[12]--"you found them all!"
   elseif(sw.n>20)then
    t="ou know, there's 40 coins about, and you only found "..tostr(sw.n).." just saying."
   end
  end
  return {c=4,t=t}
 end,
 
 --swings
 [144]=function()
  if(fd.o)then
   return{
    c=5,
    t=ts[13],--"good bye from item lost."
   }
  end

  local t=ts[14]--"i have lost item. find it"
  if(hk.w)then
   t=ts[17] --"thank you for item."
  elseif(hk.c)then
   t=ts[16] --"thank you for item. have your one"
   hk.w=true
  else
   --normal
   return {c=5,t=t,o={{t="...",f=144.1}}}
  end
  return {c=5,t=t}
 end,
 [144.1]={
  c=5,
  t=ts[15],--expl of swing
 },
 [180]=function()
  sfx(12)
  return {
	  c=8,
	  t=ts[16],--"got item",
	  o={{
	   t="let's go!",
	   f=function()
	    hk.c=true
	    mset(20,14,32)
	   end
	  }},
  }
 end,
 
 --looker
 [150]=function()--lk red tool
  if(lk.p.r)return nil--placed
  lk.h.r=true
  if(lk.h.b)then--swaping
   lk.h.b=false
   lk.p.b=true
   sfx(12)
   mset(36,10,134)
   return{
    c=8,
    t=ts[19]--"put blue where red is and swap."
   }
  else--first time
   sfx(12)
	  mset(36,10,152)
	  return {
	   c=8,
	   t=ts[20]--"take red thing",
	  }
	 end
 end,
 [152]=function()--lk red bench
  if(lk.h.r)then
   lk.h.r=false
	  mset(36,10,150)
	  return {
	   c=8,
	   t=ts[21]--"put back red thing",
	  }
  elseif(lk.h.b)then
   lk.h.b=false
   lk.p.b=true
   sfx(12)
   mset(36,10,134)
   return {
    c=8,
    t=ts[22]--"you win red then blue."
   }
  else
   return nil
  end
 end,
 [243]=function()--lk red
  if(lk.h.r)then
   sfx(13)
   return {
    c=6,
    t=ts[23],--"you stole my red tool!",
    o={tc.rs}
   }
  elseif(lk.h.b)then
   sfx(13)
   return {
    c=6,
    t=ts[24],--"get that blue tool away!",
    o={tc.rs}
   }
  elseif(lk.p.r and lk.p.b)then
   return {
    c=6,
    t=ts[25]--"you won and that was something red"
   }
  else
   return {
    c=6,
    t=ts[26]--"don't steal my red tool or else",
   }
  end
 end,
 [168]={
  c=6,
  t=ts[27]--"good bye from red tools."
 },
 [134]=function()--blue tool
  if(lk.p.b)return nil--placed
  lk.h.b=true
  if(lk.h.r)then--swaping
   lk.h.r=false
   lk.p.r=true
   sfx(12)
   mset(125,2,150)
   return {
    c=8,
    t=ts[28]--"put down the red tool and swap it for blue!"
   }
  else--first time
   sfx(12)
   mset(125,2,136)
	  return {
	   c=8,
	   t=ts[29]--"take blue thing",
	  }
  end
 end,
 [136]=function()--lk blue bench
  if(lk.h.b)then
   lk.h.b=false
	  mset(125,2,134)
	  return {
	   c=8,
	   t=ts[30]--"put back blue thing",
	  }
  elseif(lk.h.r)then
   lk.h.r=false
   lk.p.r=true
   sfx(12)
   mset(125,2,150)
   return {
    c=8,
    t=ts[31]--"you win blue then red."
   }
  else
   return nil
  end
 end,
 [247]=function()--lk blue
  if(lk.h.b)then
   sfx(13)
   return {
    c=7,
    t=ts[32],--"oit! that's my blue tool.",
    o={tc.rs}
   }
  elseif(lk.h.r)then
   sfx(13)
   return {
    c=7,
    t=ts[33],--"get that red tool out of here!",
    o={tc.rs}
   }
  elseif(lk.p.r and lk.p.b)then
   return {
    c=7,
    t=ts[34]--"you won and that was something blue"
   }
  else
   return {
    c=7,
    t=ts[35]--"don't steal my blue tool or else",
   }
  end
 end,
 [184]={
  c=7,
  t=ts[36]--"good bye from blue tools."
 },
 
 --father/son
 [160]=function()
  --dad/pink
  if(fd.o)then
   return{
    c=3,
    t=ts[37]--"good bye from pink dad."
   }
  end
  if(rb.w)then--won
   return {
    c=3,
    t=ts[38],--"thank you for talk son",
   }
  else
   return {
    c=3,
    t=ts[39],--"talk to my son",
    o={{t="...",f=160.1}}
   }
  end
 end,
 [160.1]={
  c=3,
  t=ts[40]
 },
 [178]=function()
  --son/black
  if(fd.o)then
   return{
    c=2,
    t=ts[41]--"good bye from balck son."
   }
  end
  if(rb.w)then--won
   return {
    c=2,
    t=ts[42],--"thank you for message",
   }
  else
   rb.w=true
   return {
    c=2,
    t=ts[42].."\n"..ts[43],
   }
  end
 end,
 
 --gate
 [182]=function()
  local i=0
  if(pu.f)i+=1--statue
  if(sw.w)i+=1--coins
  if(rb.w)i+=1--rainbow
  if(lk.p.r and lk.p.b)i+=1--lkr
  if(hk.w)i+=1
  
  local t="hmm - i can't head back to the ship until i find "..tostr(5-i).." more parts."
  if(i>=5)then
   sfx(12)
   t=ts[44]
   fd.o=true--final dungon open
   music(-1)
   music(11)--start ending music
   mset(51,10,46)
  end
  return {c=8,t=t}
 end,
 
 --end console
 [215]={
  c=8,
  t=ts[45],
  o={{t="sure",f=function()
   _init_end()
  end}},
 }
}
-->8
--placable behaviour

pl={--placeble state mechanic
 n=0,--plates held
 s=196,--plate sprite
 r=128,--non-plate sprite
}

function try_place()
 c=fig_cast(8,2)
 if(c==nil)return false
 if(c.m==pl.s)then--pick up
  msetp(c.x,c.y,pl.r)
  pl.n+=1
  sfx(8)
 elseif(pl.n>0)then--put down
  pl.n-=1
  msetp(c.x,c.y,pl.s)
  sfx(10)
 else
  return false
 end
 return true
end
-->8
--pushable behaviour

pu={
 s=197,--normal sprite
 p=195,--placed sprite
 e=0,--effort
 x=0,--effort application x
 y=0,--/y
 w=false,--spawned first log
 f=false,--finished
}

function try_push()
 if(pu.f and mp.n==10)then
  --can't move winning
  return false
 end
 local c=fig_cast(1,3)
 if(c==nil)return false
 --only push blocks
 if(not fget(c.m,0))return false
 --expend effort
 if(c.x==pu.x and c.y==pu.y)then
  pu.e+=1
 else
  pu.e,pu.x,pu.y=1,c.x,c.y
 end
 if(pu.e<16)return false
 --do push
 local x,y=c.x,c.y
 if(fg.d==1)x-=8
 if(fg.d==2)x+=8
 if(fg.d==3)y-=8
 if(fg.d==4)y+=8
 --blocked
 local t=mgetp(x,y)
 if(fget(t,0))return false
 if(not fget(t,3))return false
 local m=pu.s
 --placed 
 if(fget(mgetp(x,y),2))m=pu.p
 msetp(c.x,c.y,c.m+1) 
 msetp(x,y,m)
 --spawn second log
 if(not pu.w and x<0)then
  mset(58,21,pl.s)
  pu.w=true
 end
 --check win
 local p=mxyget(x,y)
 if(flr(p.mx)==45 and flr(p.my)==23)then
  pu.f=true
  show_dia(176.3)
 end
 sfx(9)
 return true
end
-->8
--cut grass behaviour

sw={
 s=211,--cut sprite
 n=0,--count
 t=false,--cutting
 f=0,--animation frame
 d=0,--/dir 1⬅️➡️⬆️⬇️4
 c=nil,--effected cast
 r=0,--animation rater
 w=false,--won
}

function try_collect()
 local x,y=fg.x+4,fg.y+4
 local m=mgetp(x,y)
 if(not fget(m,5))return false
 msetp(x,y,sw.s)
 sw.n+=1
 sfx(6)
 return true
end

function try_cut()
 --wait for animation
 if(sw.t)return false
 --trigger animation
 sw.t,sw.f,sw.d=true,0,fg.d
 sfx(5)
 --test effect 
 sw.c=fig_cast(8,4) 
 return c~=nil
end

function _update_cut()
 if(not sw.t)return
 sw.r+=1
 if(sw.f==0)sw.r=4--first timer
 if(sw.r==4)then
  sw.f+=1--move frame
  sw.r=0
 end
 if(sw.f==2 and sw.c)then
  msetp(sw.c.x,sw.c.y,sw.c.m+2)
 elseif(sw.f>3)then
  sw.t=false--end anim
 end
end

function _draw_cut()
 if(not sw.t)return
 local x=fg.x+4
 local y=fg.y+4
 local h=false
 local v=false
 if(sw.d==1)then
  x-=6
  y-=1
  h=true
  v=true
 elseif(sw.d==2)then
  x+=6
  y-=1
  v=true
 elseif(sw.d==3)then
  y-=7
  v=true
 elseif(sw.d==4)then
  y+=8
 end
 spr(211+sw.f,x-4,y-4,1,1,h,v)
end
-->8
--rainbow behaviour

rb={
 c=nil,
 w=false,--won
} 

function try_col()
 local c=fig_cast(3,6)
 if(c==nil)return false
 local l=rb.c or 7
 l+=1
 if(l>14)then
  rb.c=nil
 else
  rb.c=l
 end
 sfx(7)
 return true
end
-->8
--looker beaviour

lk={--looker state
 l={--lookers
  {--screen
   n=2,--screen
   x=39,y=7,--map x/y
   s=243,--first sprite
   v=60,--turn speed
   r=1,--rotate direction
   d=0,--direction 0⬅️⬆️➡️⬇️3
   t=0,--ticker
   h={--dialog c/t/o
    c=1,
    t="get out of here 2!",
    o={tc.ok},
   },
  },
  {
   n=7,x=116,y=9,
   s=247,
   v=60,r=1,
   d=2,t=0,
   h={
    c=1,o={tc.ok},
    t="get out of here 7.1!",
   },
  },
  {
   n=7,x=122,y=3,
   s=247,
   v=60,r=-1,
   d=0,t=0,
   h={
    c=1,o={tc.ok},
    t="get out of here 7.2!",
   },
  }
 },
 u=false,--update
 s=false,--spotted
 t={35,36},--see-thru
 h={--holding
  r=false,b=false,--red/blue  
 },
 p={--placed
  r=false,
  b=false,
 }
}

--l:looker instance
function lok_cast(l)
 --don't cast if not holding
 if(not (lk.h.r or lk.h.b))return false

 local x,y=l.x*8%128+4,l.y*8%128+4
 local dx,dy=0,0--cast delta
 if(l.d==0)dx=-8--⬅️
 if(l.d==1)dy=-8--⬆️
 if(l.d==2)dx=8 --➡️
 if(l.d==3)dy=8 --⬇️
 local h=false--hit
 local s=false--stop
 local cw=6--check width
 local ch=cw--/height
 while(not s)do 
  x+=dx
  y+=dy  
  local cx,cy=x-4-cw,y-4-ch
  --spotted
  if(fg.x>cx and fg.x<(cx+2*cw)
   and fg.y>cy and fg.y<(cy+2*ch))then
   h,s=true,true
  end
  --off edge
  if(x<0 or x>128)s=true
  if(y<0 or y>128)s=true
  --hit block
  local m=mgetp(x,y)
  if(fget(m,0))then
   s=true
   for t in all(lk.t) do
    --unless transparent
    if(m==t)s=false
   end
  end  
 end
 return h
end

function _update_lok() 
 if(mp.s.t)return--skip scroll
 local c=false--clear
 for l in all(lk.l) do
  --don't see across screens
  if(l.n==mp.n)then
   --rotate 
		 l.t+=1
		 if(l.t>l.v)then
		  l.d+=l.r
		  l.t=0
		  if(l.d>3)l.d=0
		  if(l.d<0)l.d=3
		  c=true
		 end
	  --cast
		 if(not lk.s and lok_cast(l))then
		  lk.s=true
		  show_dia(l.s)
		 end
		end
 end
 if(c)lk.s=false
end

function _draw_lok()
 for l in all(lk.l) do
  if(l.n==mp.n)mset(l.x,l.y,l.s+l.d)
 end
end
-->8
--swing behaviour

hk={--hook state
 s=false,--swinging
 dx=0,--dx to move until dest.
 dy=0,--/y
 c=false,--collected item
 w=false,--won item
}

function try_swing()
 local c=fig_cast(1,7)
 if(c==nil)return false
 --caluclate swing
 local x,y=c.x,c.y
 local dx,dy=0,0--movement delta
 if(fg.d==1)dx=-8
 if(fg.d==2)dx=8
 if(fg.d==3)dy=-8
 if(fg.d==4)dy=8
 local s=true--can swing
 local b=false--is blocked
 while(s and (not b))do
  x+=dx
  y+=dy
  local m=mgetp(x,y)
  s=fget(m,7)--is still a swing
  b=not s and fpget(m,0)--blocked
 end
 --blocked
 if(b)return false
 --start swing
 hk.s=true
 --correct landing position
 local ay,ax=0,0
 if(abs(dx)>0)then
  ay=c.y%8
 else
  ax=c.x%8
 end
 hk.dx,hk.dy=x-c.x+dx-ax,y-c.y+dy-ay
 return true
end

function _update_swg()
 if(not hk.s)return
 local ax,ay=abs(hk.dx),abs(hk.dy)
 if((ax>0 and ax%16==0)or(ay>0 and ay%16==0)or(ax==0 and ay==0))sfx(11)
 if(ax>0)then
  local d=sgn(hk.dx)
  fg.x+=d
  hk.dx-=d
 elseif(ay>0)then
  local d=sgn(hk.dy)
  fg.y+=d
  hk.dy-=d
 else
  hk.s=false
 end
end
-->8
--title behaviour

tl={
 v=false,--shown
 x=60,--ship x
 y=60,--/y
 s=200,--sprite
 t=0,--tick
 r={},--stars
 f=false,--on fire
 h=0,--horizon/frame
 p=false,--explosion
 c=-15,--exposion size
 m=true,--first screen
 i=0,--sequence
 a={201,202,201,203,201,204},
 u=false,--sounding
}

function init_stars()
 local s=flr(rnd(3)+1)
 local c={13,6,7}
 for i=1,64 do
  add(tl.r,{
   x=rnd(128),
   y=rnd(128),
   c=c[s],
   s=s,
   z=1,
  })
 end
end

function _init_tit()
 tl.v=true
 music(0)
 if(#tl.r==0)init_stars()
end

function update_world()
 for s in all(tl.r) do
  if(s.y>(128-tl.h))then
   s.c=7
   s.x-=s.s/3
   s.z=s.s*2
   if(s.y>128-tl.h+80)then
    s.c=11
    s.z=s.s*3
   end
  else
   s.x-=s.s
   s.z=1
  end
  if(s.x<0)then
   s.x=128
   s.s=flr(rnd(3)+1)
  end
 end
end

function update_fall_movie()
 if(tl.c>260)then
  tl.m=false--next
  sfx(-1)
  music(-1)
 end

 if(not tl.p and tl.x>128)then
  --explosion
  tl.p=true
  sfx(2)
 end

 if(not tl.f)then
  if(btnp(4)or btnp(5))then
   sfx(0)
   --fire
   tl.f=true
   tl.s=199
   tl.t=-16
  end
 else
  tl.x+=0.1
 end

 tl.t+=1
 if(tl.t>4)then
  tl.t=0
  if(tl.f and not tl.u)then
   tl.u=true
   sfx(1,3)
   music(1)
  end
  
  if(not tl.p)then
	  --bump ship
	  tl.x+=rnd(2)-1
	  tl.y+=rnd(2)-1
	  if(not tl.f)tl.x=mid(50,tl.x,70)
	  tl.y=mid(50,tl.y,70)
	 end
	 
	 if(tl.f)tl.h+=1
 end 
 
 update_world()
end

function draw_world()
 local h=tl.h
 --world
 rectfill(0,128-h   ,128,128-h+15,1 )
 rectfill(0,128-h+15,128,128-h+20,7 )
 rectfill(0,128-h+20,128,128-h+80,12)
 rectfill(0,128-h+80,128,128     ,3 )
 --stars/clouds/trees
 for s in all(tl.r) do
  if(s.z==1)then
   pset(s.x,s.y,s.c)
  else
   ovalfill(s.x,s.y,s.x+s.z*2,s.y+s.z,s.c)
  end
 end
end

function draw_fall_movie()
 draw_world()
 
 print(" another",48,28-tl.h,8)
 print("\nmoonshot.",10)
 if(not tl.f)then
  print("press 🅾️/❎ to start",26,100,6)
  print("@thomasmichaelwallace",42,120,5)
 end

 spr(tl.s,tl.x,tl.y)
 
 if(tl.p)then
  --explode
  tl.c+=2
  if(tl.c>0)circfill(130,80,tl.c,10)
  if(tl.c>50)circfill(130,80,tl.c-50,9)
  if(tl.c>80)circfill(130,80,tl.c-80,8)
 end
end

function update_fall_seq()
 if(tl.i==0)then
  --pause
  tl.t+=1
  if(tl.t>80)then
	  --init second
	  mp.n=5
	  tl.i=1
	  tl.y=60
	  tl.x=60
	  tl.s=201
	  tl.h=0
	 end
 elseif(tl.i==1)then
  tl.t+=1
  if(tl.t>120)then
   tl.t=0
   tl.h+=1
   if(tl.h<=#tl.a)then
    tl.s=tl.a[tl.h]
    if(tl.h==2 or tl.h==4)sfx(3)
    if(tl.h==6)sfx(4)
   else
    tl.i=2
   end
  end
  _update_map()
 elseif(tl.i==2)then
  --pause
  tl.t+=1
  if(tl.t>80)then
   music(2)
   tl.v=false
   mp.n=10--start game
   show_dia(176)
  end
 end
end

function draw_fall_seq()
 if(tl.i==1)then
  _draw_map()
  spr(tl.s,tl.x,tl.y)
 end
end

function _update_tit()
 if(tl.m)then
  update_fall_movie()
 else
  update_fall_seq()
 end
end

function _draw_tit()
 if(tl.m)then
  draw_fall_movie()
 else
  draw_fall_seq()
 end
end
-->8
--reset mechanic

function do_reset()
 --statue
 if(mp.n==11 or mp.n==12)then
  local h=false
  for x=0,15,1 do
   for y=0,15,1 do
    local m=mgetp(x*8,y*8)
    if(m==195)msetp(x*8,y*8,196)
    if(m==197)msetp(x*8,y*8,198)
    if(m==195 or m==197)h=true
   end
  end
  if(h and mp.n==11)msetp(96,32,197)
  if(h and mp.n==12)msetp(96,32,197) 
  sfx(9)
 end
 --looker
 if(mp.n==2)then--south
  if(lk.h.r)then--caught with red
   fg.x,fg.y=40,80
  elseif(lk.h.b)then--c/blue
   fg.x,fg.y=72,0
  end
 elseif(mp.n==7)then--north
  if(lk.h.r)then--c/red
   fg.x,fg.y=72,120
  elseif(lk.h.b)then--c/blue
   fg.x,fg.y=96,16
  end
 end
end

function _update_res()
 --if(btn(4)and btn(5))do_reset()
end
-->8
--final dungeon

fd={
 o=false,--open
 m=false,--movie
 e=false,--end mode
 u=false,--sounded
}

function _init_end()
 music(-1)
 fd.m=true
 tl.h=150
 tl.s=200
 tl.x=-8
 tl.y=120
 if(#tl.r==0)init_stars()
 sfx(14)
end

function _update_end()
 tl.t+=1
 if(tl.t>4)then
  tl.t=0
  --roll backdrop
  if(not tl.e and tl.h>0)tl.h-=1
	 --bump ship
		tl.x+=rnd(2)-1
		tl.y+=rnd(2)-1
	end
	if(not tl.e)then
		if(tl.x<60)tl.x+=0.3
	 if(tl.y>60)tl.y-=0.2
		tl.x=min(tl.x,70)
		tl.y=max(tl.y,60)
		if(tl.h<=0)then
		 tl.e=true
		 music(0)
		end
	else
	 tl.x=mid(50,tl.x,70)
	 tl.y=mid(50,tl.y,70)
	end
	
	if(not tl.u and tl.y<(128-tl.h))then
	 tl.u=true
	 sfx(-1)
	 sfx(15)
	end
	
 update_world()
end

function _draw_end()
 draw_world()
 spr(tl.s,tl.x,tl.y)
 
 if(tl.e)then
  print(" another",48,28-tl.h,8)
  print("\nmoonshot.",10)
  print("thanks for playing웃",26,100,9)
  print("@thomasmichaelwallace",42,120,5)
 end
end
__gfx__
0000000008888880099999900aaaaaa00bbbbbb00cccccc00eeeeee0566666650777777000b33b003b003b033bb0b30002222220022222222222222222222220
000000008288882894999949a4aaaa4ab3bbbb3bc1cccc1cedeeeede6666666677777777bbbbbbbbbbb3bbbbbbbbbbb028080802280800000000000000000802
007007008888888899999999aaaaaaaabbbbbbbbcccccccceeeeeeee66666666777777773bbb3bb3bbbbbb3bbb83bbbb20808082208000800800008008008082
000770008888888899999999aaaaaaaabbbbbbbbcccccccceeeeeeee66666666777777770bb8bbbbb8bb3bbbbbbb3bb328080802280800000000000000000802
000770008888888899999999aaaaaaaabbbbbbbbcccccccceeeeeeee66666666777777770bb33b8333bbb8bb33bbbbb320000002208000000000000000008082
007007008888888899999999aaaaaaaabbbbbbbbcccccccceeeeeeee6666666677777777b3b3b33333bb333b3333b8b020000002280800800800008008000802
000000008288882894999949a4aaaa4ab3bbbb3bc1cccc1cedeeeede6666666677777777bbb33333b33334333b33bbbb20800802208000000000000000008082
0000000008888880099999900aaaaaa00bbbbbb00cccccc00eeeeee056666665077777703bb38333333434b4333bbb3b20000002022222222222222222222220
000000008222222894444449affffffab333333b033333300dddddd077777777070700703bbbb33400000000333bb8b020000002208000000000000000000000
000000002222222244444444ffffffff3333333333bbbb33d5dddd5d76666667707000770bbbb3b400000000333bb3bb20800802280800500000000000000000
000000002222222244444444ffffffff333333333b83bbb3dddddddd7677776707000700b8bbb333000000004338bbb020000002208000000000000000000000
000000002222222244444444ffffffff333333333bbbb3b3dddddddd76777767700070003bb3b333000000003333bbbb20000002280800000000000000000000
000000002222222244444444ffffffff3333333333b3bbb3dddddddd76777767000700070bbbb3340000000033b3bb3320000002208000000000000000000000
000000002222222244444444ffffffff333333333bbbb8b3dddddddd7677776700700070bb3bb3b3000000004333bbbb20000002280800000000000000000000
000000002222222244444444ffffffff3333333333b3bb33d5dddd5d76666667770007070bb83333000000003333b3b020800802208000500000000000000000
000000008222222894444449affffffab333333b033333300dddddd077777777070070703bbb333400000000333bb8b320000002280800000000000000000000
0222222002222220000000003000300004f00f0300030003000000000000000070707070bbb33333333343343b33bbb320000002000000000003000300000000
2080808220202022000000000404040400f00f400b0000b00000000005000050070707070bb33343343b33433338bbbb20800802000000000b0000b000000000
280808022202020200000000ffffffff04f00f0030000000000000000000000000000000bbbb3333b33333333333bbb020000002000000003000000000000000
2080808220000002200000020003000030f00f40000b00300000000000000000000000003bb333bbbb3333bb3333b3b02000000200000000000b003000000000
2808080220000002200000023000000004f30f00000030000000000000000000707070703bb8bbbbbbbbb8bbb33bbbbb20808082000000000000300000000000
208080820000000022020202ffffffff00f00f4303b0000b000000000000000007070707bbbb3bb8b3bbbb3bbb83bb33280808020000000003b0000b00000000
2808080200000000202020224040404004f00f00b0000b00000000000500005000000000bbbbbbbbbbbbbbbbbbbbbbb02080808200000000b0000b0000000000
0222222000000000022222200030000330f03f4000b000300000000000000000000000000b3b0b0330b3bb03b0b33b00022222200000000000b0003000000000
0000000000000000dddddddd44444444444444440000000022222222111111115666666504004440555555554000090000000000000000000000000000000000
000000000d0000d0deeeeeed4f4004f44ffffff405000050282822821cccccc1576666754f444f44565655650a04000004000040000000000000000000000000
0000000000000000dedddded4f4004f4444444440000000022222222111111115666666504f4fff4555555550000000400f00f00000000000000000000000000
0000000000000000dedeeded4f4004f44000000400000000282222221cccccc15666666504444f44565555550000a00000000000000000000000000000000000
0000000000000000dedeeded4f4004f44000000400000000222222821cccccc15666666544f44440555555650900000900000000000000000000000000000000
0000000000000000dedddded4f4004f444444444000000002222222211111111566666654fff4040555555550004090000f00f00000000000000000000000000
000000000d0000d0deeeeeed4f4004f44ffffff405000050282282821cccccc15766667544f444f4565565650a00000004000040000000000000000000000000
0000000000000000dddddddd44444444444444440000000022222222111111115666666504440040555555550090040a00000000000000000000000000000000
00001110000011100000050000050000000000000000000000000077777000000000000000000000000000000000000000000000000000000000000000000000
00011c1100011c1100005550005550000000eee00000eee000000077777000000000000000000000000000000000000000000000000000000000000000000000
0001ccc10001ccc10005575505575500000efffe000efffe0000a4cccc4a00000000000000000000000000000000000000000000000000000000000000000000
0001ccc11111ccc10005777555777500000efffeeeeefffe0007a4cccc4a70000000000000000000000000000000000000000000000000000000000000000000
0001ccc11111ccc10005575555575500000effeeeeeeeffe0007aaaaaaaa70000000000000000000000000000000000000000000000000000000000000000000
000111111111111100055555555555000000eeeeeeeeeee00007a55aa55a70000000000000000000000000000000000000000000000000000000000000000000
00011111111111110000eeeeeeeee00000000ee77eeeeee00000a57aa75a00000000000000000000000000000000000000000000000000000000000000000000
00011177111771110000eeeeeeeee0000000eee77ee77eee0000a55aa55a00000000000000000000000000000000000000000000000000000000000000000000
000111771117711100055777577755000000eee07ee07eee0000aaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000
000111751117511100055707570755000000eee77ee77eee0000aaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000
000111111c11111100055777577755000000eeeeeee77eee0000aaaaa4aa00000000000000000000000000000000000000000000000000000000000000000000
000555111511155500055555555555000000eeeeeeeeeeee00000a4884aa00000000000000000000000000000000000000000000000000000000000000000000
00006566c5c66560000555555555550000000eeeffffeee000000aa88aa000000000000000000000000000000000000000000000000000000000000000000000
0000665655565660000555577885550000000eeeffffeee0000000aaaaa000000000000000000000000000000000000000000000000000000000000000000000
00000666ccc666000005555558855000000000eeeeeeee00000000a444a000000000000000000000000000000000000000000000000000000000000000000000
0000000666660000000055555885500000000000eeee0000000000a444a000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000fffff00000ffff0000000000000000000000000000000000000000000000000000000000000000
000009999999990000fff0000000ff0000fff0000000ff0000fffff00000ffff0000000000000000000000000000000000000000000000000000000000000000
00099999999999990fff888888888fff0fffcccccccccfff00f44ff00000f44f0000000000000000000000000000000000000000000000000000000000000000
0009ff9999999ff90ff48888888884ff0ff4ccccccccc4ff00f44ff00000f44f0000000000000000000000000000000000000000000000000000000000000000
0009ff9999999ff900f88888888888ff00fcccccccccccff00444444444444440000000000000000000000000000000000000000000000000000000000000000
0009f499999994f9008888888888888000ccccccccccccc000444444444444440000000000000000000000000000000000000000000000000000000000000000
0009f499997794f9000ffffffffffff0000ffffffffffff000444555445554440000000000000000000000000000000000000000000000000000000000000000
0009f497797794f9000fff55ff55fff0000fff55ff55fff000444555445554440000000000000000000000000000000000000000000000000000000000000000
0009f497097094f9000fff75ff57fff0000fff57ff75fff000444557447554440000000000000000000000000000000000000000000000000000000000000000
0009f497797794f9000fff55ff55fff0000fff55ff55fff000444557447554440000000000000000000000000000000000000000000000000000000000000000
0009f497799994f9000ffffffffffff0000ffffffffffff000444444444444440000000000000000000000000000000000000000000000000000000000000000
0009949999999499000fff444444fff0000fff444444fff000444444555554440000000000000000000000000000000000000000000000000000000000000000
0000099ff88f99000000fff88fffff000000fffff88fff0000444444588854440000000000000000000000000000000000000000000000000000000000000000
00000999988999000000fff88fffff000000fffff88fff000044444448e844440000000000000000000000000000000000000000000000000000000000000000
0000099999999900000000fffff00000000000fffff000000044444448e844440000000000000000000000000000000000000000000000000000000000000000
000000999999900000000000ff00000000000000ff000000004444444eee44440000000000000000000000000000000000000000000000000000000000000000
00000000cc7110013000300b000300b30000000000000000000400000000c0000000000000000000cccccccccaccccac00000000000000000000000000000000
001ccc000000000030b03b0b0b03b0030000000000000000000c00000000c0000000000000000000a11111a11111111100000000000000000000000000000000
71100ccc0000000030b03b0b3b003b0b300aa00b300aa00b00040000000040000000000000000000111a111111a11aa100000000000000000000000000000000
000000000001ccc000b30b0300300b3000a9aa0000ba9b000ff4fff00fff4ff00fffcff00ffcfff0a11111a1111a111100000000000000000000000000000000
00000000c71100ccb00300b300030b0b00aaaa00000aa0000f545ff00fff55f00fffcff00ffcfff0111a1111a11a1a1100000000000000000000000000000000
01ccc00000000000b303b3b3300b3003000aa003000aa0030f655ff00fff65f00fffcff00ffcfff011a1111a1111111100000000000000000000000000000000
1100ccc700000000b300b3b0b30033b0b00000b0b00000b000655000000065000000000000000000a1a111111a1111a100000000000000000000000000000000
0000000000001ccc0300b3000300b3000300b3000300b30000060000000060000000000000000000cccaccacccccaccc00000000000000000000000000000000
00000000000000000000000000000000000000000000000000040000000080000000000000000000000000000000000000000000000000000000000000000000
0f000f000f000f000000000000000000000000000000000000080000000080000000000000000000000000000000000000000000000000000000000000000000
09999900099999000028280000828200000000000000000000040000000040000000000000000000000000000000000000000000000000000000000000000000
0959590009595900008562000025680000056000000660000ff4fff00fff4ff00ff8fff00fff8ff0000000000000000000000000000000000000000000000000
099f9900099f9900002868000082620000006000000500000ff456f00fff55600ff8fff00fff8ff0000000000000000000000000000000000000000000000000
0999890009989900000282000008280000000000000000000ff556f00fff55f00ff8fff00fff8ff0000000000000000000000000000000000000000000000000
09999900099999000000000000000000000000000000000000055600000056000000000000000000000000000000000000000000000000000000000000000000
09000900090009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000eeeeee00eeeeee00000000011c550050000000000000000000000000000000000000000000000000000000000000000
0f000f000f000f000f000f000f000f00eeddddeeeeddddee00511100000000000080080000800800000000000000000000000000000000000000000000000000
0eeeee000eeeee000aaaaa000aaaaa00eddddddeeddddddec55001110000000000ffff0000ffff00000000000000000000000000000000000000000000000000
0e5e5e000e5e5e000a5a5a000a5a5a00ed9ddddeedddd9de000000000005111000f55f0000f55f00000000000000000000000000000000000000000000000000
0eefee000eefee000aafaa000aafaa00ed9ddddeedddd9de000000001c55001100ff8f0000f8ff00000000000000000000000000000000000000000000000000
0eee8e000ee8ee000aaa8a000aa8aa00eddddddeedddddde051110000000000000ffff0000ffff00000000000000000000000000000000000000000000000000
0eeeee000eeeee000aaaaa000aaaaa00eeddddeeeeddddee5500111c000000000088880000888800000000000000000000000000000000000000000000000000
0e000e000e000e000a000a000a000a000eeeeee00eeeeee000000000000051110080080000800800000000000000000000000000000000000000000000000000
00000000000000000000000000000000022222200aa999904444444444444444000c00c0000c00c0000000000000000000000000000000000000000000000000
0f000f000f000f0006000600060006002aa999922aaaa992450aa50445050504c00cfff0c00cfff0000000000000000000000000000000000000000000000000
0ccccc000ccccc0005555500055555002aaaa992299aaaa245a50a04450aa504ffff55f0ffff55f0000000000000000000000000000000000000000000000000
0c5c5c000c5c5c000565650005656500299aaaa22099990245aaaa0445a50a04f55ff8f0f55f8ff0000000000000000000000000000000000000000000000000
0ccfcc000ccfcc000557550005575500209999022004400245a99a0445aaaa04f8fffff0ff8ffff0000000000000000000000000000000000000000000000000
0ccc8c000cc8cc0005558500055855002004400220a9990245aaaa0445a99a04ffffccc0ffffccc0000000000000000000000000000000000000000000000000
0ccccc000ccccc00055555000555550020a99902200000024505050445aaaa04cccc00c0cccc00c0000000000000000000000000000000000000000000000000
0c000c000c000c00050005000500050002222220022222204444444444444444c00c0000c00c0000000000000000000000000000000000000000000000000000
000000000000000000000000c666666cc44ffffc5666666305555350009988000066660000000000000000000000000000000000000000000000000000000000
0000000000f00f0000f00f0066666666440000ff66666666535b55550a9877600677766000f0000000f0000000000f0000f00f00000000000000000000000000
000000000044440000444400655555564040040f6555555635553535a9888a666776aa66004444f0004444f00f44440000444400000000000000000000000000
00000000054544000044440066666666f004f00f66666666553553550a98aa666766aa6600444400004544000044540000455400000000000000000000000000
00000000008444000044440065555556f00f400f6555555653b5553ba88866656766666500444400004444000044440000448400000000000000000000000000
0000000000ff44f0004f440066666666f040040466666666b55553550988865566666655004ff400004ff400004ff400004ff400000000000000000000000000
00000000004444000044444065555556ff00004465555556555555330a9886500666655000444400004444000044440004444400000000000000000000000000
00000000004004000040000066666666cffff44c66666666055355b0009988000066550000400400004004000040040000000400000000000000000000000000
000000000000000000000000000000000000000000000000000000000eeddccccccddee000000000000000000000000000000000000000000000000000000000
00f00f0000f00f0000f00f00000000000a6666600a5050500a000000eeddcc1111ccddee00000000000000000000000000000000000000000000000000000000
0044440000444400004444003000300b000000000060505006000000eddcc111111ccdde00000000000000000000000000000000000000000000000000000000
05454400054544000044440000b00b00000000000065005006000000edcc11111111ccde00000000000000000000000000000000000000000000000000000000
00844400008444f00044440000000000000000000006050006000000edcc11111111ccde00000000000000000000000000000000000000000000000000000000
00ff44f000ff44400044f40000030003000000000006550006000000eddcc111111ccdde00000000000000000000000000000000000000000000000000000000
044444000044440004444400b00000b0000000000000600006000000eeddcc1111ccddee00000000000000000000000000000000000000000000000000000000
0000400000400400000004000300b3000000000000000000000000000eeddccccccddee000000000000000000000000000000000000000000000000000000000
00000000000000000000000006655660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000f0000f0000000f00f0065555556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f444400004444f0004444006559a556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00444400004554000045540055855b55000560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00444400004444000044840055755c55000560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0044f400004ff400004ff400655ed556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00444400004444000444440065555556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00400400004004000000040006655660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00f0000000000f0000f00f000080080000800800008008000080080000c00c0000c00c0000c00c0000c00c000000000000000000000000000000000000700700
004444f00f4444000044440000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff000000000000000000000000000000000000700700
00444400004554000045540005f5ff0000ffff0000ff5f5000f55f0005f5ff0000ffff0000ff5f5000f55f000000000000000000000000000000000000000000
004444000044840000484400008fff0000ffff0000fff80000ff8f00008fff0000ffff0000fff80000ff8f000000000000000000000000000000000000000000
004f4400004ff400004ff40000ffff8000f8ff0008ffff0000ffff0000ffffc000fcff000cffff0000ffff000000000000000000000000000000000070000007
0044440000444400004444400088880000888800008888000088880000cccc0000cccc0000cccc0000cccc000000000000000000000000000000000077000077
0040040000400400004000000080080000800800008008000080080000c00c0000c00c0000c00c0000c00c000000000000000000000000000000000007777770
__gff__
0001010101010101010101010000000000010101010101010101010100000000000000010100000001010101000000000100010101000001000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050510102020030303030303000000000303111181810303030300000000000003030303010001010303000000000000030303030303030303030000000000000000000b0c0b08000000000000000000000000000000000303000000000000000000004181000000000000000000000000000003030303030303030000000000
__map__
3030303030303030303030303030303030303030303030303939393939393900000000000000392525252525253900002a2a2a2a2a2b00292a2a2a2a2a2b17171717171717171717171717353535351700000000000000000000000000000000001b252525253925251525252515251900393939393939393919292a2a2a2a2a
300d0f300d0f92949494940d0e0e0f303030200c949294941d25258282153900393939393939393939252539393939390b252525292a2a2a2b39c639808080171735e317040435808016171617171717000000000000000000000000000000002a2b252525253925252525152525251900398225252525252519001b25252519
309494209494949420949492929292949494942c300c30303925822582823900392525252525252525252525252525391b258025252592949425c5252580802735359492043580e31716c6c535353517000000000000323232320000000000000a0a0b25252539251525252525090a19003939252523232325292a2b25862519
302094942092940c9494203030300d0f300d0f94301c30343434373737343434392524253923232323232323232323391b0b9439393925393939c63994808017170317161735170105161616171794170000323232323131313132323232000000001b2525253939393939393919001900003939252524252525f72525252519
303094309494302c922094203030300d0f929420302c30332738272727272733392524253925252525252525252525392b1b942525252539c6c6c680c5250917170317161735800205050505051794170032323131313131313131313132320000001b2525252539822525252519001923232323232524253939253925250919
302094949420309494942094303030303094209430943033273827273636273339252425392524253939392525252539001b948080808080c51539259425292a1735049217351702063535353535921732323131a4313131313131a43131323200001b25252525392515252525292a1900003925252524252525252525252919
3094943094300d0f9494929420942094942094209420301d272727273636273339252425392524252525392539252539001b9480090b943925393925252525091735e394c6c502020635030117e3941732313131a431d78a8ad831a43131323200001b2582252539252525252525822900003925232323232323232439393929
30949494209492942094303030303030303030303030301d272790272727273339822425252524f32525252525252539001b9425292b9439252525090b25942917353535171617060635920101359417323131a4a4313131313131a4a431313200001b25822525090a0b25252525090a0a0b3925253939242525252425253900
30209420300c30303020300d0f940d0e0e0e0e0e0e0e0e0e0f27272727272733392323232323242525253925392525392a2b942594922525252594292b929417171717171716171705059405053594173231313131313131313131313131313200001b2525252519001b252525091900001b3925252539242524252425253900
30942092942c300d0f92309430303030303030303030301d27272727363627333925252525253939392539253925253939252525251525258080941525949225351702949480e33503030303170392173231313131a431313131a4313131313200001b0b252525292a2b3925391919002a2b3925f72525242524252425253939
30303094949430943094309430209294949494940c30301d272727272727273339258225962525252525392539252539393939b73939392580809225399494253517028017061704040180c503039217323131a431a4a43131a4a431a43131322a2a2b1b2525252525252525090a0a0a1b393925252525252524252525252539
30209494942030209420922030949420942094942c3030343434272734343433393939252525252525253925392525252525252525253925090b94803925802535170280e39417010401c5c502359417323131a43131313131313131a43131320000001b2525252525808080190000001b823923232323232324252525252539
30942094203030303030303030209492949220303030090a0b25252525258239392539393939392539393925392525252525252525253925191b25809425353535170104359217013535161602039417323131a4a4313131313131a4a43131320a0b001b252525252580822529090a0a1b252525822525252524393939392539
309430209494949294929492949294949494920d0f3019301b252525252582393982252525252525252525252525823939252525252539090a0a0b80090b3580171701043580949435e317020203801732313131a4313131313131a431313132001b2a2b2525252525818181811900001b252525822525252525252525252539
3020949294209420942094209420303030303030b43019301b252525090a0a0a39252525252525252525252525253939398225252525391930301b80090a17171717178080801706353502021717171732323131313131313131313131313232001b2b252525252525252525252919002b393939393939252525252525393939
3030303030303030303030303030303030303030303019301b252509190000000a0a0b252525393939393939393939000a0b252525090b1930090a0a0a0a0a1730301717171717171717171717000000003231313131a43131a43131313132002a2b252525252525252525252525292a00000000000039252525252525390000
17171717171717171717171717171717252525252519292a2b2525191900000000001b252525393939393939393939392a2a2525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a19001b3231313131a43131a431313131320939393b3b3b3b3b3b3b3b3b3b3b3b393917011727170217160304170605170517
170101170104040404040404040404171717252525292a2b2525252919000000001b2b25252525252525252525252525252525252525152525252525252525292a2b2525c425252525802525252519001b32323131313131313131313132321980393b823b3b3b3b3b3b3b3b823b398017010527020216160304172705172717
17012701010606062706060606060417173434373734342525252525292a2a2a2a2b2525252525252582252525c6c6c6c6c6c6c68025252515151515151525252525251515090a0a0b808080808019001bc6323232323131313132323232c61980393b3b823b3b3b3b3b3b3b3b3b39801701050503031617030427e327172717
1727e3170606030327030303032704171735383535353325252525258225252525252525252582252525252525c62525251580808015151515252525252515151515152525292a2a2b802525252519091b0bc6c6c6323231313232c6c6c6c619a6393b3b3b3b3b3b3b3b3b3b3b3b39a617011705030427e32716021702050517
1716270606170316161605050527271717353835a0353382252525252525252525252525252525252525252525c62525251580808080808015258080c6c6c6c6c6c6c6c6c680252525802525c52529192b1bc6c6c6c6c6c6b0c6c6c6c6c60919a68080803b3b3b3b3b3b3b3b3b8080a61727e327030402170116020205270517
1716170506172705051605171717e3171735353535353434342525252525252582252525252525252525252525c62582251580c625808080152580802515151515151515c680151525802525c6252519001b0bc6b8a8c6c6c6c6c6c6090a1919a6a68080803b80803c8080808080a6a617161706062702060116170227e31717
1716030527e3270101012701012727273535353535353535332525252525252525252525252525343435343425c62525251525c6258080801525c680251525252525c6c6c6802515258025c6c6c625192a2b1bc625c625c6c6c625c619001929a6a6a6a6808080803c80803980a6a6a617161617060627060127010117270417
1703030302170304040405020517051717353a3a3a353535332525258225252525252525252534343535353325c62525251525c615152515151525c6251525151515c61580808280808080808080801900001b2525c625c625c690c6292a1900a6a6a6a639a680803c8080a6a6a6a6a617042702022703061716162716160417
1716160302022702020227022704051717353a3a3a3535353525252525252525252525252525333535353533252525252515c6c6c6c62515252525c6251525151515c61525808080252525c6c6c625190b001b25252525c62525252525251900a6a6a6a6a6a6a6a63ca6a6a6a6a6a6a61704e31702020327e317042704040417
171716030327010105050517e327061717353535353535353325252525252525258225252525333535353534373737340b25c6808080c61525c680c68080c6252525c62525258025252525c6c6c625191b2a2b39393925a0b22525252525292aa6a6a6a6a6a6a6a63ca6a6a6a6a6a6a617042703030203032727270101270117
1716161617161601010105052702061717343437373737343425252525252525252525252525333536363535353535331b25c680c680c62525c68015158080090b25c62580808080c6c615c680c6090a1b158080803925252525252525090a0aa6a6a6a6343437343c343734a6a6a6a617171717271717171717171717170117
17160427e327041717010101010206171717252525252525392525252525252525252525252533353636353535b035331b8225808080c6152525c6c6c6c680191b25c6c680c6c680c6c6c6c680c619001b808080393925252525252525190000a6a6a634343a3c3c3c3c3c3c34a6a6a600003335353535353535353533d3d324
1704040417030403270302020202061725252525152525253925252525090b82252525252525333535353535353535330a0b2525c615c62515152515c6c625292b2582c6c6c6802525c615258025292a1b8080803925252525a225252519090aa6a634343a3a3a3ca23c383c37a6a6a60000333535353535353a3a3533d38224
1701012703031727e327170606060617251525252525152539822525090a0a0a0a0b2525822533353535383536353434000a0b25c6c6c6c680c68080c6c625090a0b252580808025252525258080801917278080090a0a0b2525252725291917a6a6a634343a3c3c3c3c383c34a6a6a600003335383535b23535353533d38224
170117e327021716270417060505051725252515252525253939393919000000001b252525253335353538353535330000000a0a0a0b2525808015801525090a0a0a0a0a0a0a0a0b252525090a0a0a0a172727271917171b2525272727272917a6a6a6a63434373437343734a6a6a6a600003335383535353533343434232315
1701172717021716030417060517051725252525252525252525252519000000001b252525253434343434343434330000000000000a0a0a0a0a0a0a0a0a0a00000000000000001b0a0a0a190000000017171717171717171717170000000017a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a600003334343437373733000000000000
__sfx__
010200000067300273006730027300674002620066200262006620026200664002640066400254006520025200652002520063200232006320023400634002340062400224006240022200612002120061200212
0110001e0d6110c22106631062310a621092110c6110d2110a6110b2110e6211022108621052110463106231086310a23108621112210a6110e61112621146310e62110621106210e6310c6310a6110a61108621
0108141f106560c6260e6260e6460f64615646176461764623646246462564627666296662d66631656366563a6563d6563f6663f6663a6663a6663a666396563b6563b6663967639666396563a6663d6663d666
01170000243551c7001d7001c7001a700187001870000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011700002435030351303510c25100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00003c6140c615001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001833530355000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c3430c345000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000182450c323000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000226000c6211f611156211f611096000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c32318245000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800000c2340e235000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000182352b235242350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000000000c251302513025000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01141c1f03630096300b6300763007630046300363001630076300c6300d6300d6300d6300d6300d6300f63012630176301a6301f63024630286302e63031630326303263031630336303563036630396303a630
0114000035630180351e6302203511650090550b6500065003650180551f055300553005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
013c00001c0351d0351f035000001c0351d0351f0350000024035000001f03500000000001d0351c035000001c0351d0351a035000001c0351d0351a0350000021035000001f0351d0351c035000001c03500000
011400001c3351e3351f335003051c3351e3351f335003051c3351e3351f3351e3351f3351e3351f335003051c3352333521335003051c3352333521335003051c33523335213351f335213351f3352133500305
011400002421223212242122321224212232122421223212242122321224212232122421223212242122321224212232122421223212242122321224212232122421223212242122321224212232122421223212
011400000942009421094250842507420074210742508425094200942109425084250742007421074250842509420094210942508425074200742107425064250542005421054250642507420074210742506425
012d00001c5201d5201f5251f5001c5201d5201f5251f50024520245251f52500500005001d5201c525005001c5201d5201a525005001c5201d5201a5250050021520215251f5201d5201c525005001c52500500
012d00000000000000005450000000000000000054500000000000000000545000000000000000005450000000000000000254500000000000000002545000000000000000005450000000000000000054500000
011e000028115291152b115001051c1151d1151f1150010528115291152b1152911528115291152b11500105261152811529115001051a1151c1151d115001052611528115291152811526115281152911500105
011e000028115291152b115001051c1151d1151f1150010528115291152b115301152f115301152d11500105261152811529115001051a1151c1151d11500105281152b1152b1152911528115261152411500105
012800001c1101d1101f1101c0101d0101f0101c1101d1101f1101c0101d0101f01000000241101f110000001f1101d110000001d1101c1100000000000000001c1101d1101a1101c0101d0101a0101c1101d110
012800001a1101c0101d0101a01000000210101f010000001d0101c010000001a0101801000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012800000000000000187251f7251f725187251f7251f725187251f7251f725187251f7251f7251a7251d7251d7251a7251d7251d725187251c7251c7251872500000000001a7251c7251c7251a7251c7251c725
012800001a7251c7251c7251a7251c7251c7251c7251f7251f7251a725117251d725187251c7251c7251872500000000000000000000000000000000000000000000000000000000000000000000000000000000
011e00000431504315053150531507315000000731600006043150431505315053150731500000073160000602315023150431504315053150000005316000060231502315043150431505315000000531600006
011e000000405004052940529405284112841524405264052f4112f4152f4052d4112d4112d4112d41100405004052941528411264152641126411000002e4112e4112e4112e4012d4112d4152d4152d41500000
011e0000004052d4152d41529401284112841524405284012941129415294152f4112f4112f41500000000002e4152d4112c4152b4112a4150000000000000000000026415284112641500000000002141121415
013c00001b7221d7221e725000021b7221d7221e7250000222722227222072220722207221d7221b7221b7251b7221d7221e722000021b7221d7221e72200002227222272221722207221e7221a7221b7221b725
013c00001c7221e7221f725000001c7221e7221f7250000023722237252172221725247222472523722237251c7221e7221f725000001c7222372221725000001c7222472223722217021772518725197251a725
013c000000000000000f4121641212412164120f4121641212412164120f4121641212412164120f4120000000000000000d4121641211412164120d4121641211412164120d4121641211412164120d41200000
013c00000000000000104121741213412174121041217412134121741210412174121341217412104120000000000000000e4121741213412174120e4121741213412174120e412174120b4120c4120d4120e412
011e000000000000000c115000001811518115000000c1150c115000000c115000001811518115000000c1150e1151011511115000001d1151d115000001111511115000000000011115000000e1150c1150c115
011e00000000000000101151111513115000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001322511225102250020013225112251022500200132251122510225002001322500200102250020011225102250e2250020011225102250e2250020011225102250e2250020011225002000e22500200
0110000000000000001c21028210000001d21029210000001f2102b210000001f2102b210000001c2102821000000000001c21028210000001d21029210000001f2102b21000000212102d210000001a21026210
0110000000000000001c2102821000000212102d21000000232102f2100000000000000000000028210282100000000000212102d21000000232102f210000002421030210000000000000000000002821028210
011000000015300000001530000000000001531c633000000015300000001530000000000001531c633000000015300000001530000000000001531c633000000015300000001530000000000001531c63300000
__music__
03 10514344
03 11121344
03 14154344
01 181b4344
02 1a191c44
01 1d1e4344
02 1d1f4344
01 20224344
02 21234344
01 16244344
02 17244344
01 26272944
00 26272944
00 26282944
02 26272844

