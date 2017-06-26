window.onload = function() {

const bus = new Vue();

Vue.component('past-form', {
  props: ['lastpasts', 'test'],
  template: `<div class="Middle">
			<div class="LeftSide">
				<div class="CodeBlock">				
					  <textarea placeholder="Your code here..." v-model=mycode></textarea> 
				</div>
				<div class="BottomButtons">
					<div class="LngList" v-for="(lang, index) in languages">
					
					 	<button @click="clickOnLanguage(lang.lang, index)" :class="{'ui inverted orange button': !lang.isClicked , 'ui orange button': lang.isClicked}">{{lang.lang}}</button>

					</div>
					<div class="SendItem">
						<button class="ui brown button" :disabled="isReadyToSend" @click="sendClick($event)">Send</button>
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
			
		</div>`,
		data () {
		return {
				mycode: '',
				languages: [
					{lang:'D', isClicked: false},
					{lang:'C#', isClicked: false},
					{lang:'Dart', isClicked: false},
					{lang:'Text', isClicked: false}
				],
				selectedLanguage: ''
			}
		},
		methods: {
			sendClick(e)
	  		{
	  			bus.$emit('codechange', this.mycode, this.selectedLanguage);
	  		},
	  		clickOnLanguage(language, index)
	  		{
				for(n of this.languages)
					{
						if(n.lang == language)
						{
							 this.selectedLanguage = n.lang;
							 n.isClicked = true;
						}
						else
							n.isClicked = false;
					}
	  		}

		},
		computed: {
			isReadyToSend()
			{
				if(this.selectedLanguage != "" && this.mycode.length>1)
					return false;
				else
					return true;
			}
		}

})


Vue.component('view-form', {
	props: ['mycode'],
 	template: `
  		<div class="ViewCodeContainer">
				<div class="ViewCode">
					<code> {{mycode}} </code>
				</div>
		</div>`
})

var app = new Vue({
  el: '#app',
  data: {
    currentView: 'past-form',
    mycode: '',
    language: '',
    responseURL: '',
    lastpasts : []
  },
  methods:
  {
  	changeView()
  	{
  		this.currentView = 'view-form';
  		console.log(this.mycode);
  		console.log("this.responseURL", this.responseURL);
  		history.pushState(null, null, '/' + this.responseURL);
  		window.location.href = '/' + this.responseURL;
  	},

  	sendCode()
  	{
		var obj = {};
		var data = {};
		obj.language = this.language.replace(`C#`, `csharp`);
		obj.code = this.mycode;
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
	bus.$on('codechange', function(mycode, language){
		this.mycode = mycode;
		this.language = language;
		// this.changeView();
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