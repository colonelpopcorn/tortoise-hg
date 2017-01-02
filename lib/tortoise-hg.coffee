{CompositeDisposable} = require 'atom'

module.exports = TortoiseHg =
  tortoiseHgView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @tortoiseHgView = new TortoiseHgView(state.tortoiseHgViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @tortoiseHgView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'tortoise-hg:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @tortoiseHgView.destroy()

  serialize: ->
    tortoiseHgViewState: @tortoiseHgView.serialize()

  toggle: ->
    console.log 'TortoiseHg was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
