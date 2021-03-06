controller  = null
user        = null
router      = null

describeWith = (store) ->
  describe "Tower.Controller.Resourceful (Tower.Store.#{store.name})", ->
    beforeEach (done) ->
      App.User.store(store)
      App.User.destroy =>
        App.User.create id: 1, firstName: "Lance", done
        
    beforeEach (done) ->
      Tower.start(done)

    afterEach ->
      Tower.stop()
    
    describe 'format: "json"', ->
      describe "success", ->
        test '#index', (done) ->
          _.get "/custom", format: "json", (response) ->
            resources = response.body
            assert.isArray resources
            assert.isArray @collection
            assert.equal typeof(@resource), "undefined"
            assert.equal resources.length, 1
            assert.equal resources[0].firstName, "Lance"
            assert.equal @headers["Content-Type"], "application/json"
            
            App.User.count (error, count) =>
              assert.equal count, 1
              done()
            
        test '#new', (done) ->
          _.get '/custom/new', format: "json", ->
            resource = JSON.parse(@body)
            assert.equal typeof(@collection), "undefined"
            assert.equal typeof(@resource), "object"
            assert.equal resource.firstName, undefined
            assert.equal @headers["Content-Type"], "application/json"
          
            App.User.count (error, count) =>
              assert.equal count, 1
              done()
        
        test '#create', (done) ->
          _.post '/custom', format: "json", params: user: firstName: "Lance", (response) ->
            resource = response.body
            assert.equal resource.firstName, "Lance"
            assert.equal @headers["Content-Type"], "application/json"
          
            App.User.count (error, count) =>
              assert.equal count, 2
              done()
        
        test '#show', (done) ->
          _.get "/custom/1", format: "json", (response) ->
            resource = JSON.parse(@body)
            assert.equal resource.firstName, "Lance"
            assert.equal resource.id, 1
            assert.equal @headers["Content-Type"], "application/json"
          
            App.User.count (error, count) =>
              assert.equal count, 1
              done()
    
        test '#edit', (done) ->
          _.get '/custom/1/edit', format: "json", (response) ->
            resource = JSON.parse(@body)
            assert.equal resource.firstName, "Lance"
            assert.equal resource.id, 1
            assert.equal @headers["Content-Type"], "application/json"
          
            App.User.count (error, count) =>
              assert.equal count, 1
              done()
        
        test '#update', (done) ->
          _.put '/custom/1', format: "json", params: user: firstName: "Dane", (response) ->
            resource = JSON.parse(@body)
            assert.equal resource.firstName, "Dane"
            assert.equal resource.id, 1
            assert.equal @headers["Content-Type"], "application/json"
          
            App.User.find 1, (error, user) =>
              assert.equal user.get("firstName"), "Dane"
            
              App.User.count (error, count) =>
                assert.equal count, 1
                done()

        test '#destroy', (done) ->
          _.destroy '/custom/1', format: "json", (response) ->
            resource = response.body
            assert.equal resource.firstName, "Lance"
            assert.equal resource.id, undefined
            assert.equal @headers["Content-Type"], "application/json"
          
            App.User.count (error, count) =>
              assert.equal count, 0
              done()
              
      describe "failure", ->
        test '#create'
        
        test '#update'
              
        test '#destroy'
        
    describe 'format: "html"', ->
      describe 'success', ->
        test '#index', (done) ->
          _.get '/custom', (response) ->
            assert.equal @body, '<h1>Hello World</h1>\n'
            assert.equal @headers["Content-Type"], "text/html"
        
            App.User.count (error, count) =>
              assert.equal count, 1
              done()
              
        test '#new', (done) ->
          _.get '/custom/new', ->
            assert.equal @action, "new"
            assert.equal @body, '<h1>New User</h1>\n'
            assert.equal @headers["Content-Type"], "text/html"
        
            App.User.count (error, count) =>
              assert.equal count, 1
              done()
        
        test '#create', (done) ->
          params = user: firstName: "Lance"
          
          _.post '/custom.html', params: params, (response) ->
            assert.equal @action, "show"
            assert.equal response.text, "<h1>Hello Lance</h1>\n"
            assert.equal @headers["Content-Type"], "text/html"
            
            App.User.count (error, count) =>
              assert.equal count, 2
              done()
              
        test '#show', (done) ->
          _.get '/custom/1', (response) ->
            assert.equal response.text, "<h1>Hello Lance</h1>\n"
            assert.equal @headers["Content-Type"], "text/html"
            
            App.User.count (error, count) =>
              assert.equal count, 1
              done()
              
        test '#edit', (done) ->
          _.get '/custom/1/edit', (response) ->
            assert.equal response.text, '<h1>Editing User</h1>\n'
            assert.equal @headers["Content-Type"], "text/html"
            
            App.User.count (error, count) =>
              assert.equal count, 1
              done()
            
        test '#update', (done) ->
          _.put '/custom/1.html', params: user: firstName: "Dane", (response) ->
            assert.equal @action, "show"
            assert.equal response.text, '<h1>Hello Dane</h1>\n'
            assert.equal @headers["Content-Type"], "text/html"
            
            App.User.find 1, (error, user) =>
              assert.equal user.get("firstName"), "Dane"
        
              App.User.count (error, count) =>
                assert.equal count, 1
                done()
        
        test '#destroy', (done) ->
          _.destroy '/custom/1.html', (response) ->
            assert.equal @action, "index"
            assert.equal response.text, '<h1>Hello World</h1>\n'
            assert.equal @headers["Content-Type"], "text/html"
        
            App.User.count (error, count) =>
              assert.equal count, 0
              done()
              
describeWith(Tower.Store.Memory)
unless Tower.client
  describeWith(Tower.Store.MongoDB)
