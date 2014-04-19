db = require "mongoose"
passport = require "passport"

###
# API base class, provides useful methods for route implementation
###
class APIBase

  constructor: (options) ->
    @_model = options.model
    @_populateQueries = options.populate or []

  ###
  # Get API model name
  #
  # @return [String] model
  ###
  getModel: -> @_model

  ###
  # Get default query population field list
  #
  # @return [Array<String>] fields
  ###
  getPopulateFields: -> @_populateQueries

  ###
  # Fetch all models
  #
  # @param [Response] res
  # @param [Method] cb
  ###
  queryAll: (res, cb) ->
    @queryRaw { type: "find" }, {}, res, cb

  ###
  # Execute a find query against our model
  #
  # @param [Object] query
  # @param [Response] res
  # @param [Method] cb
  ###
  query: (query, res, cb) ->
    @queryRaw { type: "find" }, query, res, cb

  ###
  # Find a single model
  #
  # @param [Object] query
  # @param [Response] res
  # @param [Method] cb
  ###
  queryOne: (query, res, cb) ->
    @queryRaw { type: "findOne" }, query, res, cb

  ###
  # Find a model by ID
  #
  # @param [Object] id string or ObjectId
  # @param [Response] res
  # @param [Method] cb
  ###
  queryId: (id, res, cb) ->
    @queryRaw { type: "findById" }, id, res, cb

  ###
  # Find a model by owner
  #
  # @param [Object] owner string or ObjectId
  # @param [Response] res
  # @param [Method] cb
  ###
  queryOwner: (owner, res, cb) ->
    @queryRaw { type: "find" }, { owner: owner }, res, cb

  ###
  # Low level query method, takes an explicit query type and list of fields
  # to populate
  #
  # @param [Object] options
  # @option options [Array<String>] populate list of fields to populate
  # @option options [String] type query type (find, findById, findOne, etc)
  # @param [Object] query
  # @param [Respons] res
  # @param [Method] cb
  ###
  queryRaw: (options, query, res, cb) ->
    options.populate or= @_populateQueries
    options.type or= "find"

    rawQuery = db.model(@_model)[options.type] query
    rawQuery.populate(pop) for pop in options.populate
    rawQuery.exec (err, objects) ->
      return res.send 500 if err

      cb objects

  ###
  # Passport API authentication middleware to pass to requests
  #
  # @param [Request] req
  # @param [Response] res
  # @param [Method] next
  ###
  apiLogin: (req, res, next) ->
    return next() if req.isAuthenticated()

    passport.authenticate("localapikey", session: false, (err, user, info) ->
      return next err if err
      return res.send 403 unless user

      req.user = user
      next()
    ) req, res, next

module.exports = APIBase
