
GlobalData_Num = class("GlobalData_Num")
GlobalData_Num.__index = GlobalData_Num

function GlobalData_Num:ctor()
    cclog("GlobalData_Num::ctor")
    self:init()
end

function GlobalData_Num:init( ... )
	self.m_nMaxScore  = cc.UserDefault:getInstance():getIntegerForKey( "gameNum_maxScroe", 0)
	
end

function GlobalData_Num:setGameNumMaxScore( _maxScore)

    if  _maxScore > self.m_nMaxScore then
        self.m_nMaxScore = _maxScore
        cc.UserDefault:getInstance():setIntegerForKey( "gameNum_maxScroe", self.m_nMaxScore)
        cc.UserDefault:getInstance():flush() 
    end
end

function GlobalData_Num:getGameNumMaxScore( )

    return self.m_nMaxScore
end

function GlobalData_Num.create()
    cclog("GlobalData_Num.create")
    local   instance = GlobalData_Num.new()
    return  instance
end