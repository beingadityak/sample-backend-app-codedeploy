var cheerio = require('cheerio'),
	request = require('request');

/*
	@getAmulLatest - scrape the latest amul topical available from webpage
*/
function getAmulLatest(){
	let curYear = new Date().getFullYear();
	let url = `http://www.amul.com/m/amul-hits?s=${curYear}`;
	let baseUrl = 'http://www.amul.com';

	return new Promise((resolve, reject) =>{
		request(url, (err,response,body)=>{
			if(err) reject(err);
			// cheerio for scraping
			var $ = cheerio.load(body);
			var source = $('td:first-child img').attr('src');

			var apiResponse = {
				image:`${baseUrl}${source}` 
			};
			resolve(apiResponse);
		})
	});
}


// make the api available as an express endpoint
module.exports = (app,express)=>{
	var amulApi = express.Router();
	
	// returning the result in the main endpoint only...
	amulApi.get('/', (req,res)=>{
		getAmulLatest().then((apiResponse)=>{
			res.status(200).json(apiResponse);
		});
	});

	return amulApi;
}