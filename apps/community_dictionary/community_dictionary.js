// ==========================================================================
// Project:   CommunityDictionary
// Copyright: ©2011 My Company, Inc.
// ==========================================================================
/*globals CommunityDictionary */

// CommunityDictionary = SC.Application.create();
// 
// jQuery(document).ready(function() {
//   CommunityDictionary.mainPane = SC.TemplatePane.append({
//     layerId: 'community_dictionary',
//     templateName: 'community_dictionary'
//   });
// });


var CommunityDictionary = SC.Application.create({ store: SC.Store.create().from('CommunityDictionary.RESTDataSource') });

CommunityDictionary.Term = SC.Object.extend({
  term: null
});

CommunityDictionary.termListController = SC.ArrayController.create({
  content: [],

  createTerm: function(phrase) {
      var term = CommunityDictionary.Term.create({ term: phrase });
      this.pushObject(term);
  }
});
 
 
var terms;

jQuery(document).ready(function() {
  console.log("Document ready");
  CommunityDictionary.mainPane = SC.TemplatePane.append({
    layerId: "community_dictionary",
    templateName: "community_dictionary"
  });
  
  terms = CommunityDictionary.store.find(CommunityDictionary.Term);
  CommunityDictionary.termListController.set('content', terms);
});

CommunityDictionary.CreateTermView = SC.TemplateView.create(SC.TextFieldSupport, {
  insertNewline: function() {
    var value = this.get('value');
 
    if (value) {
      CommunityDictionary.termListController.createTerm(value);
      this.set('value', '');
    }
  }
});

CommunityDictionary.termListView = SC.TemplateCollectionView.create({
  contentBinding: 'CommunityDictionary.termListController'
});





