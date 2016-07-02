using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.ActivityMonitor as Act;
using Toybox.Time as Time;

class demoView extends Ui.WatchFace {

	hidden var centerX, centerY, radius;
	
	hidden const CIRCLE_R_1 = 50;
	hidden const OFFSET_Y = 0;
    function initialize() {
        WatchFace.initialize();
    }

    //! Load your resources here
    function onLayout(dc) {
 
    	centerX = dc.getWidth() / 2;
		centerY = dc.getHeight() / 2 + OFFSET_Y;
		radius = centerX < centerY ? centerY : centerX;

 //       setLayout(Rez.Layouts.WatchFace(dc));
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {		
  
    }

    //! Update the view
    function onUpdate(dc) {
        // Get the current time and format it correctly    
        clear(dc);
		//draw time ticks
		drawSticks(dc);
		//draw time handle with time str
		drawHandle(dc);
        // Call the parent onUpdate function to redraw the layout
        drawInnerCircle(dc);
        //draw downpart ticks
        drawDownTicks(dc);
        //draw down part haldle with str
        drawDownHandle(dc);
        //draw text in center circle 
        drawTextInCricle(dc); 
       
       
   //    drawInterPoint(dc);
       //draw arc of data etc.
  //     drawArc(dc);	
  		drawStepPro(dc);
    }
    
    function drawStepPro(dc) {
    	var info = Act.getInfo();
    	
    	var step = info.steps.toFloat();
    	var step_g = info.stepGoal.toFloat();
   
   Sys.println("step:" + step + "  Goal:" + step_g); 	
    	var angle =  (1 + step / step_g) * 180;
    	
    	dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_ORANGE);
    	dc.setPenWidth(2);
    	dc.drawArc(centerX, centerY, CIRCLE_R_1 + 10, dc.ARC_COUNTER_CLOCKWISE, 179, angle);
    }
    
    hidden const MON_R = CIRCLE_R_1 - 10;
    hidden const WEEK_R = MON_R - 12;
    hidden const NOTIFY_R = WEEK_R - 12;
    hidden const BATT_R = NOTIFY_R - 12;
    function drawArc(dc) {
    //-------------month
    	var now = Time.now();
    	var date = Time.Gregorian.info(now, Time.FORMAT_SHORT);
    	var mon_angle = 90 - date.month *360  / 12;
    Sys.println("mon_angle:" + mon_angle);	
    	dc.setPenWidth(4);
    	dc.drawArc(centerX, centerY, MON_R, dc.ARC_CLOCKWISE, 90, mon_angle);
      	dc.drawText(centerX, centerY - MON_R, Gfx.FONT_XTINY, date.month.toString(), Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
    //-----------------week-------------
   		var week_angle = 90 - date.day_of_week * 360 / 7;
   		Sys.println("week:" + week_angle);
   	    dc.drawArc(centerX, centerY, WEEK_R + 4, dc.ARC_CLOCKWISE, 90, week_angle);	
   		dc.drawText(centerX, centerY - WEEK_R, Gfx.FONT_XTINY, date.day_of_week.toString(), Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);

    	//-------------------------notify ------------ 
    	var notify_angle = 360 * Sys.getDeviceSettings().notificationCount / 32;
       	dc.drawArc(centerX, centerY, NOTIFY_R + 4, dc.ARC_CLOCKWISE, 90,  notify_angle);	
    	dc.drawText(centerX, centerY - NOTIFY_R, Gfx.FONT_XTINY, Sys.getDeviceSettings().notificationCount.toString(), Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);

    	
    	//--------------batttery-------------------------
    	var batt_life = Sys.getSystemStats().battery.toLong();    	
  	 	Sys.println("batt_angle :" + (90 - batt_life * 360 /100));
  	    dc.drawArc(centerX, centerY, BATT_R + 4, dc.ARC_CLOCKWISE, 90, 90 - batt_life * 360 / 100);	
    	dc.drawText(centerX, centerY - BATT_R, Gfx.FONT_XTINY, batt_life.toString(), Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);

    }
    hidden const POINT_R = 2;
    function drawInterPoint(dc) {
    	var x1, y1, cos, sin;
    	var radius = CIRCLE_R_1 - 4;
    	dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_WHITE);
    	for (var i = 0, angle = 0; i <= 4; i++) {
			cos = Math.cos(angle);
			sin = Math.sin(angle);
    		
    		x1 = radius * cos;
    		y1 = radius * sin;
    		
    		dc.fillCircle(centerX + x1, centerY + y1, POINT_R);
    		dc.fillCircle(centerX + x1, centerY - y1, POINT_R);
    		dc.fillCircle(centerX - x1, centerY - y1, POINT_R);
    		dc.fillCircle(centerX - x1, centerY + y1, POINT_R);
    		
    		dc.fillCircle(centerX + y1, centerY + x1, POINT_R);
    		dc.fillCircle(centerX + y1, centerY - x1, POINT_R);
    		dc.fillCircle(centerX - y1, centerY - x1, POINT_R);
    		dc.fillCircle(centerX - y1, centerY + x1, POINT_R);
    		
    		angle += Math.PI / 16;
    	}
    }
    
	function drawTextInCricle(dc) {
		var now = Time.now();
		Sys.println("now:" + now.value());
		var days = Time.Gregorian.info(now, Time.FORMAT_MEDIUM);
		Sys.println(days.year+ ":" + days.month + ":" + days.day);
		Sys.println("notify:" + Sys.getDeviceSettings().notificationCount);
		
		var date_str = Lang.format("$1$-$2$", [days.month, days.day]);
		var week_str = Lang.format("$1$", [days.day_of_week]);
		var notify_str = Lang.format("Ntf:$1$", [Sys.getDeviceSettings().notificationCount]);
		var alarm_str;
		if (Sys.getDeviceSettings().alarmCount > 0){
			alarm_str = Lang.format("ala:$1$", [Sys.getDeviceSettings().alarmCount]);
		} else {
			alarm_str = "ala:no";
		}
		var batt_str = Lang.format("batt:$1$%", [Sys.getSystemStats().battery.toNumber()]);
		
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
		dc.drawText(centerX - 4, centerY - 30, Gfx.FONT_TINY, date_str, Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
		dc.drawText(centerX + 20, centerY - 10, Gfx.FONT_TINY, week_str, Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
		dc.drawText(centerX - 20, centerY - 10, Gfx.FONT_TINY, notify_str , Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
		dc.drawText(centerX + 10, centerY + 30, Gfx.FONT_TINY, alarm_str , Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
		dc.drawText(centerX - 10, centerY + 10, Gfx.FONT_TINY, batt_str , Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
	}
	
    hidden const HR_MAX = 200.0;
    function drawDownHandle(dc) {
    	var hr_i =  Act.getHeartRateHistory(1, true);
    	var hr = hr_i.next().heartRate;

    	var angle = ( 1.0 - (hr / HR_MAX)) * Math.PI;
    
    	dc.setPenWidth(2);	
    	dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_RED);
    	dc.drawLine(centerX + radius * Math.cos(angle), centerY + radius* Math.sin(angle), centerX + CIRCLE_R_1* Math.cos(angle) , centerY + Math.sin(angle)*CIRCLE_R_1);
 	
    	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    	var hr_str = Lang.format("$1$", [hr]);
    	dc.drawText(centerX, centerY + CIRCLE_R_1 + 30, Gfx.FONT_MEDIUM, hr_str, Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
    }
    
    function drawDownTicks(dc) {
    	var x1, x2, y1, y2, len;
		var radians = Math.PI / 48.0;

		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
			dc.setPenWidth(1);
		for ( var i = 0, angle = 0; i < 13; i++) {
			
			var cos = Math.cos(angle);
			var sin = Math.sin(angle);
			if (i % 4 == 0) {
				len = 90;
			} else {
				len = 70;//radius;
			}
			x1 = CIRCLE_R_1 * cos;
			y1 = CIRCLE_R_1 * sin;
			x2 = len * cos;
			y2 = len * sin;
			
			dc.drawLine(centerX + x1, centerY + y1, centerX + x2, centerY + y2);
			dc.drawLine(centerX - x1, centerY + y1, centerX - x2, centerY + y2);
			dc.drawLine(centerX - y1, centerY + x1, centerX - y2, centerY + x2);
			dc.drawLine(centerX + y1, centerY + x1, centerX + y2, centerY + x2);
			angle += radians;
		}
		
    }
    
    function drawInnerCircle(dc) {
    
    	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
    	dc.fillCircle(centerX, centerY, CIRCLE_R_1);
    }
    
	function clear(dc) {
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
		dc.clear();
	}
	
	function timeAngle() {
		var time = Sys.getClockTime();
		var minutes = time.min + time.hour * 60;
		Sys.println("time.hour " + time.hour + ":" + time.min);
		Sys.println("minutes:" + minutes);
		return ((minutes) / 1440.0 ) * Math.PI + Math.PI;
//		return 0;//Math.PI;
		
	} 
	function drawHandle(dc) {
		var angle = timeAngle();
		var length = radius + 1;
		var cos =  Math.cos(angle);
		var sin = Math.sin(angle);
		
		var pointX = centerX + length * cos;
		var pointY = centerY + length * sin;
			Sys.println("angle " + angle );	
		dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_RED);
		dc.drawLine(centerX  + cos*CIRCLE_R_1, centerY + sin*CIRCLE_R_1, pointX, pointY);
		
		var time = Sys.getClockTime();
    	var time_str = Lang.format("$1$:$2$", [time.hour.format("%02d"), time.min.format("%02d")]);
    	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    	dc.drawText(centerX, centerY - CIRCLE_R_1 - 20, Gfx.FONT_MEDIUM, time_str, Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
	}
	function drawSticks(dc) {
		var oedge = radius + 1;
		var radians = Math.PI / 48.0;
		
		System.println("drawSticks");
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
		for(var i = 0, angle = 0; i < 13; i++) {
			var iedge, cos, sin, x1, x2, y1, y2;
			
			if (i%4 == 0) {
		//		dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_BLACK);
				dc.setPenWidth(2);
				iedge = oedge - (i % 12 == 0 ? 15 : 10);
			}else {
				dc.setPenWidth(1);
				iedge = oedge - 10;
			}
			cos = Math.cos(angle);
			sin = Math.sin(angle);
		
			x1 = iedge * cos;
			x2 = oedge * cos;
			y1 = iedge * sin;
			y2 = oedge * sin;
			
            dc.drawLine(centerX - x1, centerY - y1, centerX - x2, centerY - y2);
            dc.drawLine(centerX + x1, centerY - y1, centerX + x2, centerY - y2);
            dc.drawLine(centerX - y1, centerY - x1, centerX - y2, centerY - x2);
            dc.drawLine(centerX + y1, centerY - x1, centerX + y2, centerY - x2);

            angle += radians;
		}
		System.println("end of drawSticks");
	}
    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
