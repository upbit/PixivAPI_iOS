/**
 * @providesModule PixivAPI
 * @flow
 */
'use strict';

var PixivAPI = require('NativeModules').PixivAPI;

module.exports = {
	loginIfNeeded: function(username:string, password:string, callback:Function) {
		PixivAPI.loginIfNeeded(username, password, callback);
	},
	
	// SAPI
	SAPI_ranking: function(page:number, mode:string, content:string, requireAuth:boolean, callback:Function) {
		PixivAPI.SAPI_ranking( page, mode, content, requireAuth, (results) => callback(JSON.parse(results)) );
	},
	SAPI_ranking_log: function(year:number, month:number, day:number, mode:string, page:number, requireAuth:boolean, callback:Function) {
		PixivAPI.SAPI_ranking_log( year, month, day, mode, page, requireAuth, (results) => callback(JSON.parse(results)) );
	},
	SAPI_member_illust: function(author_id:number, page:number, requireAuth:boolean, callback:Function) {
		PixivAPI.SAPI_member_illust( author_id, requireAuth, (results) => callback(JSON.parse(results)) );
	},

	// PAPI
	PAPI_works: function(illust_id:number, callback:Function) {
		PixivAPI.PAPI_works( illust_id, (results) => callback(JSON.parse(results)) );
	},
	PAPI_users: function(author_id:number, callback:Function) {
		PixivAPI.PAPI_users( author_id, (results) => callback(JSON.parse(results)) );
	},
	PAPI_me_feeds: function(show_r18:boolean, callback:Function) {
		PixivAPI.PAPI_me_feeds( show_r18, (results) => callback(JSON.parse(results)) );
	},
	PAPI_users_favorite_works: function(author_id:number, page:number, publicity:boolean, callback:Function) {
		PixivAPI.PAPI_me_feeds( author_id, page, publicity, (results) => callback(JSON.parse(results)) );
	},
};
