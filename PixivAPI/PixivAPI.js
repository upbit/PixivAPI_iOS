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
  PAPI_users_works: function(author_id:number, page:number, publicity:boolean, callback:Function) {
      PixivAPI.PAPI_users_works( author_id, page, publicity, (results) => callback(JSON.parse(results)) );
  },
	PAPI_users_favorite_works: function(author_id:number, page:number, publicity:boolean, callback:Function) {
		PixivAPI.PAPI_users_favorite_works( author_id, page, publicity, (results) => callback(JSON.parse(results)) );
	},
  PAPI_ranking_all: function(mode:string, page:number, callback:Function) {
    PixivAPI.PAPI_ranking_all( mode, page, (results) => callback(JSON.parse(results)) );
  },
  PAPI_ranking_log: function(mode:string, page:number, date:string, callback:Function) {
    PixivAPI.PAPI_ranking_log( mode, page, date, (results) => callback(JSON.parse(results)) );
  },
};
