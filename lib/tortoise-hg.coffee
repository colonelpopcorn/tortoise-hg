{CompositeDisposable} = require 'atom'
path = require "path"
fs = require "fs"

tortoiseHg = (args, cwd) ->
  spawn = require("child_process").spawn
  command = atom.config.get("tortoise-hg.tortoisePathForWindows") + "/thg.exe"
  options =
    cwd: cwd

tProc = spawn(command, args, options)

tproc.stdout.on "data", (data) ->
  console.log "stdout: " + data

tproc.stderr.on "data", (data) ->
  console.log "stderr: " + data

tproc.on "close", (code) ->
  console.log "child process exited with code " + code

resolveTreeSelection = ->
  if atom.packages.isPackageLoaded("tree-view")
    treeView = atom.packages.getLoadedPackage("tree-view")
    treeView = require(treeView.mainModulePath)
    serialView = treeView.serialize()
    serialView.selectedPath

resolveEditorFile = ->
  editor = atom.workspace.getActivePaneItem()
  file = editor?.buffer.file
  file?.path

blame = (currFile)->
  stat = fs.statSync(currFile)
  args =  [ "/command:blame" ]
  if stat.isFile()
    args.push("/path:"+path.basename(currFile))
    cwd = path.dirname(currFile)
  else
    args.push("/path:.")
    cwd = currFile
  # there is a problem with tortoiseHg 1.9+ and passing the -1 as the endrev value
  #     the -1 is interpreted as another paramater
  #     quoting works from the command line (i.e. /endrev:"-1")
  # args.push("/startrev:1", "/endrev:-1") if atom.config.get("tortoise-svn.tortoiseBlameAll")
  # console.log "invoking tortoiseHg with args=", args
  tortoiseHg(args, cwd)

commit = (currFile)->
  stat = fs.statSync(currFile)
  if stat.isFile()
    tortoiseHg(["/command:commit", "/path:"+path.basename(currFile)], path.dirname(currFile))
  else
    tortoiseHg(["/command:commit", "/path:."], currFile)

diff = (currFile)->
  stat = fs.statSync(currFile)
  if stat.isFile()
    tortoiseHg(["/command:vdiff", "/path:"+path.basename(currFile)], path.dirname(currFile))
  else
    tortoiseHg(["/command:vdiff", "/path:."], currFile)
#+
log = (currFile)->
  stat = fs.statSync(currFile)
  if stat.isFile()
    tortoiseHg(["/command:log","/path:"+path.basename(currFile)], path.dirname(currFile))
  else
    tortoiseHg(["/command:log","/path:."], currFile)


revert = (currFile)->
  stat = fs.statSync(currFile)
  if stat.isFile()
    tortoiseHg(["/command:revert", "/path:"+path.basename(currFile)], path.dirname(currFile))
  else
    tortoiseHg(["/command:revert", "/path:."], currFile)

update = (currFile)->
  stat = fs.statSync(currFile)
  if stat.isFile()
    tortoiseHg(["/command:update", "/path:"+path.basename(currFile)], path.dirname(currFile))
  else
    tortoiseHg(["/command:update", "/path:."], currFile)

###
May not work with thg
thgswitch = (currFile) ->
  stat = fs.statSync(currFile)
  if stat.isDirectory()
    target = currFile
  else
    target = path.parse(currFile).dir

  tortoiseHg(["/command:switch", "/path:"+target], target)
###

add = (currFile) ->
  stat = fs.statSync(currFile)
  if stat.isFile()
    tortoiseHg(["/command:add", "/path:"+path.basename(currFile)], path.dirname(currFile))
  else
    tortoiseHg(["/command:add", "/path:."], currFile)

rename = (currFile) ->
  stat = fs.statSync(currFile)
  if stat.isFile()
    tortoiseHg(["/command:rename", "/path:"+path.basename(currFile)], path.dirname(currFile))
  else
    tortoiseHg(["/command:rename", "/path:."], currFile)

lock = (currFile) ->
  stat = fs.statSync(currFile)
  if stat.isFile()
    tortoiseHg(["/command:lock", "/path:"+path.basename(currFile)], path.dirname(currFile))
  else
    tortoiseHg(["/command:lock", "/path:."], currFile)
###
May not work with thg
unlock = (currFile) ->
  stat = fs.statSync(currFile)
  if stat.isFile()
    tortoiseHg(["/command:unlock", "/path:"+path.basename(currFile)], path.dirname(currFile))
  else
    tortoiseHg(["/command:unlock", "/path:."], currFile)
###

module.exports = TortoiseHg =
  config:
    tortoisePathForWindows:
      title: "Tortoise Hg bin path"
      description: "The folder that contains our process"
      type: "string"
      default: "C:/Program Files/TortoiseHg"
    tortoiseBlameAll:
      title: "Blame all versions"
      description: "Default to looking at all versions in the file's history." +
        " Uncheck to allow version selection."
      type: "boolean"
      default: true

  activate: (state) ->
    atom.commands.add "atom-workspace", "tortoise-hg:blameFromTreeView": => @blameFromTreeView()
    atom.commands.add "atom-workspace", "tortoise-hg:blameFromEditor": => @blameFromEditor()

    atom.commands.add "atom-workspace", "tortoise-hg:commitFromTreeView": => @commitFromTreeView()
    atom.commands.add "atom-workspace", "tortoise-hg:commitFromEditor": => @commitFromEditor()

    atom.commands.add "atom-workspace", "tortoise-hg:diffFromTreeView": => @diffFromTreeView()
    atom.commands.add "atom-workspace", "tortoise-hg:diffFromEditor": => @diffFromEditor()

    atom.commands.add "atom-workspace", "tortoise-hg:logFromTreeView": => @logFromTreeView()
    atom.commands.add "atom-workspace", "tortoise-hg:logFromEditor": => @logFromEditor()

    atom.commands.add "atom-workspace", "tortoise-hg:revertFromTreeView": => @revertFromTreeView()
    atom.commands.add "atom-workspace", "tortoise-hg:revertFromEditor": => @revertFromEditor()

    atom.commands.add "atom-workspace", "tortoise-hg:updateFromTreeView": => @updateFromTreeView()
    atom.commands.add "atom-workspace", "tortoise-hg:updateFromEditor": => @updateFromEditor()

    atom.commands.add "atom-workspace", "tortoise-hg:openWorkbenchFromTreeView": => @updateFromTreeView()
    atom.commands.add "atom-workspace", "tortoise-hg:openWorkbenchFromEditor": => @updateFromEditor()

    atom.commands.add "atom-workspace", "tortoise-hg:switchFromTreeView": => @switchFromTreeView()

    atom.commands.add "atom-workspace", "tortoise-hg:addFromTreeView": => @addFromTreeView()
    atom.commands.add "atom-workspace", "tortoise-hg:addFromEditor": => @addFromEditor()

    atom.commands.add "atom-workspace", "tortoise-hg:renameFromTreeView": => @renameFromTreeView()
    atom.commands.add "atom-workspace", "tortoise-hg:renameFromEditor": => @renameFromEditor()

    atom.commands.add "atom-workspace", "tortoise-hg:lockFromTreeView": => @lockFromTreeView()
    atom.commands.add "atom-workspace", "tortoise-hg:lockFromEditor": => @lockFromEditor()

    atom.commands.add "atom-workspace", "tortoise-hg:unlockFromTreeView": => @unlockFromTreeView()
    atom.commands.add "atom-workspace", "tortoise-hg:unlockFromEditor": => @unlockFromEditor()

  blameFromTreeView: ->
    currFile = resolveTreeSelection()
    blame(currFile) if currFile?

  blameFromEditor: ->
    currFile = resolveEditorFile()
    blame(currFile) if currFile?

  commitFromTreeView: ->
    currFile = resolveTreeSelection()
    commit(currFile) if currFile?

  commitFromEditor: ->
    currFile = resolveEditorFile()
    commit(currFile) if currFile?

  diffFromTreeView: ->
    currFile = resolveTreeSelection()
    diff(currFile) if currFile?

  diffFromEditor: ->
    currFile = resolveEditorFile()
    diff(currFile) if currFile?

  logFromTreeView: ->
    currFile = resolveTreeSelection()
    log(currFile) if currFile?

  logFromEditor: ->
    currFile = resolveEditorFile()
    log(currFile) if currFile?

  revertFromTreeView: ->
    currFile = resolveTreeSelection()
    revert(currFile) if currFile?

  revertFromEditor: ->
    currFile = resolveEditorFile()
    revert(currFile) if currFile?

  updateFromTreeView: ->
    currFile = resolveTreeSelection()
    update(currFile) if currFile?

  updateFromEditor: ->
    currFile = resolveEditorFile()
    update(currFile) if currFile?

  switchFromTreeView: ->
    currFile = resolveTreeSelection()
    tsvnswitch(currFile) if currFile?

  addFromTreeView: ->
    currFile = resolveTreeSelection()
    add(currFile) if currFile?

  addFromEditor: ->
    currFile = resolveEditorFile()
    add(currFile) if currFile?

  renameFromTreeView: ->
    currFile = resolveTreeSelection()
    rename(currFile) if currFile?

  renameFromEditor: ->
    currFile = resolveEditorFile()
    rename(currFile) if currFile?

  lockFromTreeView: ->
    currFile = resolveTreeSelection()
    lock(currFile) if currFile?

  lockFromEditor: ->
    currFile = resolveEditorFile()
    lock(currFile) if currFile?

  unlockFromTreeView: ->
    currFile = resolveTreeSelection()
    unlock(currFile) if currFile?

  unlockFromEditor: ->
    currFile = resolveEditorFile()
    unlock(currFile) if currFile?
