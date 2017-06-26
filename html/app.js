window.onload = function() {

const bus = new Vue();

Vue.component('past-form', {
  props: ['lastpasts', 'test'],
  template: `
  	<div class="SubContainer">
			<div class="Header">
				<div class="MyHeader"><a href="/">past-code</a></div>

				<button @click="splitView = !splitView">Split View</button>
			</div>

	  		<div class="Middle">
				<div class="LeftSide">
					<div class="CodeBlockContainer">
						<div class="CodeBlockContainerOne">
							
							<div class="CodeBlock">
								  <div class="CodeBlockView"><textarea placeholder="Your code here..." v-model=mycodeOne></textarea></div> <!-- Show one -->
							</div>
							<div class="BottomButtons">
								<div class="LngList" v-for="(lang, index) in languagesOne">
								 	<button @click="clickOnLanguageOne(lang.lang, index)" :class="{'ui inverted orange button': !lang.isClicked , 'ui orange button': lang.isClicked}">{{lang.lang}}</button>
								</div>

								<div class="SendItem" v-if="!splitView">
									<button class="ui brown button" :disabled="isReadyToSend" @click="sendClick($event)">Send</button>
								</div>
							</div>

						</div>

						<div class="CodeBlockContainerTwo" v-if="splitView"> <!-- Add to display second -->
							
							<div class="CodeBlock">
								  <div class="CodeBlockView"><textarea placeholder="Your code here..." v-model=mycodeTwo></textarea></div>
							</div>
							<div class="BottomButtons">
								<div class="LngList" v-for="(lang, index) in languagesTwo">
								 	<button @click="clickOnLanguageTwo(lang.lang, index)" :class="{'ui inverted orange button': !lang.isClicked , 'ui orange button': lang.isClicked}">{{lang.lang}}</button>
								</div>

								<div class="SendItem">
									<button class="ui brown button" :disabled="isReadyToSend" @click="sendClick($event)">Send</button>
								</div>
							</div>


						</div>

					</div>
				</div>

				<div class="RightSide">
					<div class="RightTop">
						My Last Code-Paste
					</div>
					<div class="RightDown">
						<div style="padding-bottom: 5px;" v-for="el in lastpasts">
							<a class="LastPastsLinkStyle" :href=el.url>{{el.date}}</a>
						</div>	
					</div>
				</div>
				
			</div>
		</div>
			`,
		data () {
		return {
				mycodeOne: '',
				mycodeTwo: '',
				languagesOne: [
					{lang:'D', isClicked: false},
					{lang:'C#', isClicked: false},
					{lang:'Dart', isClicked: false},
					{lang:'Text', isClicked: false}
				],

				languagesTwo: [
					{lang:'D', isClicked: false},
					{lang:'C#', isClicked: false},
					{lang:'Dart', isClicked: false},
					{lang:'Text', isClicked: false}
				],

				selectedLanguageOne: '',
				selectedLanguageTwo: '',
				splitView : false
			}
		},
		methods: {
			sendClick(e)
	  		{
	  			bus.$emit('codechange', this.mycodeOne, this.selectedLanguageOne, this.mycodeTwo, this.selectedLanguageTwo);
	  		},
	  		clickOnLanguageOne(language, index)
	  		{
				for(n of this.languagesOne)
					{
						if(n.lang == language)
						{
							 this.selectedLanguageOne = n.lang;
							 n.isClicked = true;
						}
						else
							n.isClicked = false;
					}
	  		},

	  		clickOnLanguageTwo(language, index)
	  		{
				for(n of this.languagesTwo)
					{
						if(n.lang == language)
						{
							 this.selectedLanguageTwo = n.lang;
							 n.isClicked = true;
						}
						else
							n.isClicked = false;
					}
	  		},


		},
		computed: {
			isReadyToSend()
			{
				if(this.splitView) //if splitview is true
				{
					if(this.selectedLanguageOne != "" && this.mycodeOne.length>1 && this.selectedLanguageTwo != "" && this.mycodeTwo.length>1)
						return false;
					else
						return true;					
				}

				if(!this.splitView)
				{
					if(this.selectedLanguageOne != "" && this.mycodeOne.length>1)
						return false;
					else
						return true;
				}

			}
		}

})


Vue.component('view-form', {
	props: ['mycodeOne'],
 	template: `
  		<div class="ViewCodeContainer">
				<div class="ViewCode">
					<code> {{mycodeOne}} </code>
				</div>
		</div>`
})

var app = new Vue({
  el: '#app',
  data: {
    currentView: 'past-form',
    mycodeOne: '',
    mycodeTwo: '',
    languageOne: '',
    languageTwo: '',
    responseURL: '',
    lastpasts : []
  },
  methods:
  {
  	changeView()
  	{
  		this.currentView = 'view-form';
  		// console.log(this.mycodeOne);
  		console.log("this.responseURL", this.responseURL);
  		history.pushState(null, null, '/' + this.responseURL);
  		window.location.href = '/' + this.responseURL;
  	},

  	sendCode()
  	{
		var obj = {};
		var data = {};
		obj.languageOne = this.languageOne.replace(`C#`, `csharp`);
		obj.codeOne = this.mycodeOne;
		if(languageTwo.length != "") // if second language is used
		{
			obj.splitView = true;
			obj.languageTwo = this.languageTwo.replace(`C#`, `csharp`);
			obj.codeTwo = this.mycodeTwo;
		}

		data.data = obj;

		this.$http.post('/post', data).then(response => {		

		  if(response.status == 200)
		  {
		  	console.log(response.body);
		  	this.responseURL = response.body;
		  	let storageObj = {};
		  	storageObj.date = (new Date().toLocaleString());
		  	storageObj.url = this.responseURL;
			localStorage.setItem(storageObj.date, storageObj.url);
			//console.log(storageObj);
		  	this.changeView()

		  }
		  else
		   	console.log("Wrong response code ", response.status);

		  }, response => {
		    console.log("Can't send data to server: ", response.status);
		  });

  	}  	

  }, 

  created() // all other events
  {  		
	bus.$on('codechange', function(mycodeOne, languageOne, mycodeTwo, languageTwo){
		this.mycodeOne = mycodeOne;
		this.language = languageOne;
		this.mycodeTwo = mycodeTwo;
		this.languageTwo = languageTwo;

		this.sendCode();

	}.bind(this));

  },

  mounted()
  {
  	for(let obj of Object.entries(localStorage))
	{
		// this.lastpasts.push(obj);
		// console.log("--> ", this.lastpasts);
		var x = {};
		x.url = obj[1];
		x.date = obj[0];
		this.lastpasts.push(x);

	}
  }


})


}