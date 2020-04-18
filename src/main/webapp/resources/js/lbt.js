// JavaScript Document
$(function(){
	var tNum=0;
	var dNum=0;
	var timer=null;
	$('.inCon ul').append($('.inCon ul li').eq(0).clone(true));
	/*右按钮的工作，点击右按钮，让图片向左跑一张*/
	function autoPlay(){
		dNum++;
		if(dNum>6){dNum=0}
		$('.btnList li').eq(dNum).addClass('current').siblings().removeClass('current');
		tNum++;
		if(tNum>7){
			tNum=1;
			$('.inCon ul').css('left','0px')
			}
		var move=tNum*-680;
		$('.inCon ul').stop().animate({'left':''+move+'px'},500)	
	}
	$('.right').click(function(){
	//alert(1)	
		autoPlay()
	})
	
	/*左按钮的工作，点击左按钮，让图片向右跑一张*/
	$('.left').click(function(){
	//alert(1)	
		dNum--;
		if(dNum<0){dNum=6}
		$('.btnList li').eq(dNum).addClass('current').siblings().removeClass('current');
		tNum--;
		if(tNum<0){
			tNum=6;
			$('.inCon ul').css('left','-4760px')
			}
		var move=tNum*-680;
		$('.inCon ul').stop().animate({'left':''+move+'px'},500)
	})
	/*点击圆点，跳到相应图片的位置*/
	$('.btnList li').click(function(){
		/*让图片跳到相应的索引值*-520的位置*/
		$(this).addClass('current').siblings().removeClass('current');
		var move=$(this).index()*-680;
		$('.inCon ul').stop().animate({'left':''+move+'px'},500);
		dNum=$(this).index();
		tNum=$(this).index();
	})
	/*添加定时器*/
	timer=setInterval(autoPlay,3000)
	
	/*鼠标移上停止定时器，鼠标离开启动定时器*/
	$('.con').hover(function(){
		clearInterval(timer);
	},function(){
		clearInterval(timer);
		timer=setInterval(autoPlay,3000)
	})
	
})