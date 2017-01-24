var currentProgressRegular = 0;
var currentProgressMax = 0;
var arrivalTime;
var calculatedEndTime;
var calculatedMaxTime;
var diffNowEndTime;
var diffNowMaxTime;
var diffNowStartTime;
var regularTimePart;
var extraTimePart;


function update(hours, minutes, seconds){
    arrivalTime = new Date();
    arrivalTime.setHours(hours,minutes,seconds);

    calculatedEndTime = new Date(arrivalTime.getTime());
    var endTimeHours = calculatedEndTime.getHours()+settings.regularWorkingTimeHours;
    var endTimeMinutes = calculatedEndTime.getMinutes()+settings.regularWorkingTimeMinutes;
    if(settings.addBreakTimeToRegularDailyWorkingTime){
        endTimeHours += settings.regularBreakTimeHours;
        endTimeMinutes += settings.regularBreakTimeMinutes;
    }
    calculatedEndTime.setHours(endTimeHours, endTimeMinutes);

    calculatedMaxTime = new Date(arrivalTime.getTime());
    var maxTimeHours = calculatedMaxTime.getHours()+settings.maximumWorkingTimeHours;
    var maxTimeMinutes = calculatedMaxTime.getMinutes()+settings.maximumWorkingTimeMinutes;
    if(settings.addBreakTimeToRegularDailyWorkingTime){
        maxTimeHours += settings.regularBreakTimeHours;
        maxTimeMinutes += settings.regularBreakTimeMinutes;
    }
    calculatedMaxTime.setHours(maxTimeHours, maxTimeMinutes);

    var diffStartEndTime = getDiff(calculatedEndTime,arrivalTime);
    var diffStartMaxTime = getDiff(calculatedMaxTime,arrivalTime);
    var regularMinutes = diffStartEndTime.minutes + diffStartEndTime.hours*60
    var extraMinutes = diffStartMaxTime.minutes + diffStartMaxTime.hours*60 - regularMinutes
    regularTimePart = regularMinutes / (regularMinutes+extraMinutes)
    extraTimePart = extraMinutes / (regularMinutes+extraMinutes)

    var now = new Date();

    diffNowEndTime = getDiff(now,calculatedEndTime);
    diffNowMaxTime = getDiff(now,calculatedMaxTime);
    diffNowStartTime = getDiff(now,arrivalTime);

    if(diffNowEndTime.sign < 0){
        currentProgressRegular = getPercent(arrivalTime,calculatedEndTime,now);
        currentProgressMax = 0;
    }else{
        if(diffNowMaxTime.sign < 0){
            currentProgressMax = getPercent(calculatedEndTime,calculatedMaxTime,now);
        }else{
            currentProgressMax = 1;
        }
        currentProgressRegular = 1;
    }

}

function getPercent(start, end, value){
    var s = start.getTime();
    var e = end.getTime();
    var v = value.getTime();
    return (v-s)/(e-s);
}

function getDiff(dateA, dateB){
    var diff_ms = dateA.getTime()-dateB.getTime();
    var sign = Math.sign(diff_ms);
    diff_ms = Math.abs(diff_ms);
    diff_ms = diff_ms/1000;
    var seconds = Math.floor(diff_ms % 60);
    diff_ms = diff_ms/60;
    var minutes = Math.floor(diff_ms % 60);
    diff_ms = diff_ms/60;
    var hours = Math.floor(diff_ms % 24);
    var days = Math.floor(diff_ms/24);

    var diff = {
        'days': days,
        'hours': hours,
        'minutes': minutes,
        'seconds': seconds,
        'sign': sign
    }
    return diff;
}

Math.sign = Math.sign || function(x) {
  x = +x; // convert to a number
  if (x === 0 || isNaN(x)) {
    return x;
  }
  return x > 0 ? 1 : -1;
}
