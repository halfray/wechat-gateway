# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(()->
  data = {
    sendUsers: [],
    users: [
      {NickName: 'a'},
      {NickName: 'b'}
    ],
    sendUserNames: []
    message: '',
    messages: [
    ],
    messageGroup: {}
  }

  formElement = (el) ->
    if el.data('nifty-check')
      return
    else
      el.data 'nifty-check', true
      if el.text().trim().length
        el.addClass 'form-text'
      else
        el.removeClass 'form-text'
    input = el.find('input')[0]
    groupName = input.name
    $groupInput = do ->
      if input.type == 'radio' and groupName
        $('.form-radio').not(el).find('input').filter('input[name=' + groupName + ']').parent()
      else
        false

    changed = ->
      if input.type == 'radio' and $groupInput.length
        $groupInput.each ->
          $gi = $(this)
          if $gi.hasClass('active')
            $gi.trigger 'nifty.ch.unchecked'
          $gi.removeClass 'active'
          return
      if input.checked
        el.addClass('active').trigger 'nifty.ch.checked'
      else
        el.removeClass('active').trigger 'nifty.ch.unchecked'
      return

    if input.checked
      el.addClass 'active'
    else
      el.removeClass 'active'
    $(input).on 'change', changed
    return

  methods =
    isChecked: ->
      @[0].checked
    toggle: ->
      @[0].checked = !@[0].checked
      @trigger 'change'
      null
    toggleOn: ->
      if !@[0].checked
        @[0].checked = true
        @trigger 'change'
      null
    toggleOff: ->
      if @[0].checked and @[0].type == 'checkbox'
        @[0].checked = false
        @trigger 'change'
      null

  $.fn.niftyCheck = (method) ->
    chk = false
    @each ->
      if methods[method]
        chk = methods[method].apply($(this).find('input'), Array::slice.call(arguments, 1))
      else if typeof method == 'object' or !method
        formElement $(this)
      return
    chk

  nifty.document.ready ->
    allFormEl = $('.form-checkbox, .form-radio')
    if allFormEl.length
      allFormEl.niftyCheck()
    return

  check = ()->
    allFormEl = $('.form-checkbox, .form-radio')
    if allFormEl.length
      allFormEl.niftyCheck()


  $.ajax({
    url: '/gate_way/contact_list',
    success: (result)->
      data.users = result.MemberList
      setTimeout(check, 2000)
  })

  new Vue({
    el: '#gateway',
    data: data,
    methods:
      sendMessage: ()->
        return alert '请选择发送对象' unless this.sendUsers && this.sendUsers.length

        text = this.message.trim()
        currentTime = new Date().getHours() + ":" + new Date().getMinutes()
        that = this
        $.ajax({
          url: '/gate_way/sends',
          method: 'POST',
          data: {users: this.sendUsers, message: text},
          success: ()->
            that.messages.push({text: text, currentTime: currentTime})
            that.message = ''
          fail: ()->
            alert '发送失败，请等会再试'
        })
      getUser: (user_id)->
        this.messageGroup[this.sendUsers.join(':')] = this.messages
        if this.sendUsers.indexOf(user_id) == -1
          this.sendUsers.push(user_id)
        else
          this.sendUsers.splice(this.sendUsers.indexOf(user_id), 1)
        this.sendUserNames = []
        for userId in this.sendUsers
          for user in this.users
            console.log user.UserName == userId
            if user.UserName == userId
              this.sendUserNames.push(user.NickName)

        this.messages = this.messageGroup[this.sendUsers.join(':')]
        this.messages = [] if not this.messages
  })
);