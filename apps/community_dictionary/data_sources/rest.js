// ==========================================================================
// Project:   CommunityDictionary.RestDataSource
// Copyright: ©2011 My Company, Inc.
// ==========================================================================
/*globals CommunityDictionary */

/** @class

  (Document Your Data Source Here)

  @extends SC.DataSource
*/
CommunityDictionary.RestDataSource = SC.DataSource.extend(
/** @scope CommunityDictionary.RestDataSource.prototype */ {

  // ..........................................................
  // QUERY SUPPORT
  // 

  fetch: function(store, query) {
    SC.Request.getUrl('/terms/').json()
    .notify(this, 'fetchDidComplete', store, query)
    .send()

    return YES;
  },
  
  fetchDidCompleteLogOnly: function(response, store, query) {
    console.log("in fetchDidCompleteLogOnly");
  },

  fetchDidComplete: function(response, store, query) {
    console.log("in fetchDidComplete");
    if(SC.ok(response)) {
      var recordType = query.get('term'),
      records = response.get('body');
    
      store.loadRecords(recordType, records);
      store.dataSourceDidFetchQuery(query);
    
    } else {
      // Tell the store that your server returned an error
      store.dataSourceDidErrorQuery(query, response);
    }
  },

  // ..........................................................
  // RECORD SUPPORT
  // 
  
  retrieveRecord: function(store, storeKey) {
    
    // TODO: Add handlers to retrieve an individual record's contents
    // call store.dataSourceDidComplete(storeKey) when done.
    
    return NO ; // return YES if you handled the storeKey
  },
  
  createRecord: function(store, storeKey) {
    
    // TODO: Add handlers to submit new records to the data source.
    // call store.dataSourceDidComplete(storeKey) when done.
    
    return NO ; // return YES if you handled the storeKey
  },
  
  updateRecord: function(store, storeKey) {
    
    // TODO: Add handlers to submit modified record to the data source
    // call store.dataSourceDidComplete(storeKey) when done.

    return NO ; // return YES if you handled the storeKey
  },
  
  destroyRecord: function(store, storeKey) {
    
    // TODO: Add handlers to destroy records on the data source.
    // call store.dataSourceDidDestroy(storeKey) when done
    
    return NO ; // return YES if you handled the storeKey
  }
  
}) ;
