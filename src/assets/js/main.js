//load the CSS and images that are used in it
import '../css/screen.css';


window.onscroll = () => {
	scrollFunction();
};



let funcGetPosition = () => {
	if(document.body.scrollTop != document.documentElement.scrollTop){
		return document.documentElement.scrollTop;
	}

	return document.body.scrollTop;
};

//set current scroll position
let numScrollPosition = funcGetPosition();
let numGlobalNavPosition = 200;
let numHeadingPosition = 250;
let numCutOff = 400;

function scrollFunction() {
	let numOldPosition = numScrollPosition;
	numScrollPosition = funcGetPosition();

	//if below nav show masthead
	if(numScrollPosition > numGlobalNavPosition){
		document.getElementById('header').className = 'masthead';
	}else{
		document.getElementById('header').className = '';
	}

	//if below title show title in masthead
	if(numScrollPosition > numHeadingPosition){
	//	document.getElementById('masthead-title').style.display = 'inline-block';
	}else{
	//	document.getElementById('masthead-title').style.display = 'none';
	}

	//if below title hide masthead
	if(numScrollPosition > numCutOff){
	//	document.getElementById('header').className = '';
	}else{
	//	document.getElementById('header').className = 'masthead';
	}

	//if scrolled up and below the cut off show the header
	if(numScrollPosition < numOldPosition){
	//	document.getElementById('header').className = 'masthead';
	}

}