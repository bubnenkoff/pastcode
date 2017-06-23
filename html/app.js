window.onload = function() {

const bus = new Vue();

Vue.component('past-form', {

  template: `<div class="Middle">
			<div class="LeftSide">
				<div class="CodeBlock">				
					  <textarea placeholder="Your code here..." v-model=mycode></textarea> 
				</div>
				<div class="BottomButtons">
					<div class="LngList">
						<label v-for="lang in languages">
						    <input type="radio" name="languages"
						      v-model="selectedLanguage" :value="lang.lang">
						    	<span>{{lang.lang}}</span>
						  </label>
					</div>
					<div class="SendItem">
						<button class="ui brown button" :disabled="selectedLanguage.length == 0 " @click="sendClick($event)">Send</button>
					</div>
				</div>
			</div>

			<div class="RightSide">
				<div class="RightTop">
					My Last Past
				</div>
				<div class="RightDown">
					<div class="ui divided items">
						  <div class="item">
						    <div class="ui tiny image">
						      <img src="/images/wireframe/image.png">
						    </div>
						    <div class="middle aligned content">
						      Content A
						    </div>
						  </div>
						  <div class="item">
						    <div class="ui tiny image">
						      <img src="/images/wireframe/image.png">
						    </div>
						    <div class="middle aligned content">
						      Content B
						    </div>
						  </div>
						  <div class="item">
						    <div class="ui tiny image">
						      <img src="/images/wireframe/image.png">
						    </div>
						    <div class="middle aligned content">
						      Content C
						    </div>
						  </div>
						</div>
				</div>
			</div>
			
		</div>`,
		data () {
		return {
				mycode: '',
				languages: [
					{lang:'D'},
					{lang:'C#'},
					{lang:'Dart'},
					{lang:'Text'}
				],
				selectedLanguage: ''
			}
		},
		methods: {
			sendClick(e)
	  		{
	  			if(this.mycode.length > 0 || this.selectedLanguage != "")
	  				bus.$emit('codechange', this.mycode, this.selectedLanguage);
	  			else
	  				console.log("Someting wrong");
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
    responseURL: ''
  },
  methods:
  {
  	changeView()
  	{
  		this.currentView = 'view-form';
  		console.log(this.mycode);
  		console.log("this.responseURL", this.responseURL);
  		history.pushState(null, null, '/' + this.responseURL);
  	//s	window.location.href = '/' + this.responseURL;
  	},

  	sendCode()
  	{
		var obj = {};
		var data = {};
		obj.language = this.language.replace(`C#`, `csharp`);
		obj.code = this.mycode;
		data.data = obj;
		//obj = JSON.stringify(obj);
		// var myobj = JSON.stringify(obj);
		console.log("Code is sended to server");
		console.log("data +++: ", data);
		this.$http.post('/post', data).then(response => {		

		  if(response.status == 200)
		  {
		  	console.log(response.body);
		  	this.responseURL = response.body;
		  	this.changeView()
		  	console.log("this.responseURL ", this.responseURL);
		  }
		  else
		   	console.log("Wrong response code ", response.status);

		  }, response => {
		    console.log("Can't send data to server: ", response.status);
		  });

  	}  	

  }, 

  created()
  {  		
	bus.$on('codechange', function(mycode, language){
		this.mycode = mycode;
		this.language = language;
		// this.changeView();
		this.sendCode();

	}.bind(this));

  }


})


}