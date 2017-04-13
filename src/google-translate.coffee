# Description:
#   Allows Hubot to know many languages.
#
# Commands:
#   hubot translate me <phrase> - Searches for a translation for the <phrase> and then prints that bad boy out.
#   hubot translate me from <source> into <target> <phrase> - Translates <phrase> from <source> into <target>. Both <source> and <target> are optional

languages =
  "af": "Afrikaans",
  "sq": "Albanian",
  "ar": "Arabic",
  "az": "Azerbaijani",
  "eu": "Basque",
  "bn": "Bengali",
  "be": "Belarusian",
  "bg": "Bulgarian",
  "ca": "Catalan",
  "zh-CN": "Simplified Chinese",
  "zh-TW": "Traditional Chinese",
  "hr": "Croatian",
  "cs": "Czech",
  "da": "Danish",
  "nl": "Dutch",
  "en": "English",
  "eo": "Esperanto",
  "et": "Estonian",
  "tl": "Filipino",
  "fi": "Finnish",
  "fr": "French",
  "gl": "Galician",
  "ka": "Georgian",
  "de": "German",
  "el": "Greek",
  "gu": "Gujarati",
  "ht": "Haitian Creole",
  "iw": "Hebrew",
  "hi": "Hindi",
  "hu": "Hungarian",
  "is": "Icelandic",
  "id": "Indonesian",
  "ga": "Irish",
  "it": "Italian",
  "ja": "Japanese",
  "kn": "Kannada",
  "ko": "Korean",
  "la": "Latin",
  "lv": "Latvian",
  "lt": "Lithuanian",
  "mk": "Macedonian",
  "ms": "Malay",
  "mt": "Maltese",
  "no": "Norwegian",
  "fa": "Persian",
  "pl": "Polish",
  "pt": "Portuguese",
  "ro": "Romanian",
  "ru": "Russian",
  "sr": "Serbian",
  "sk": "Slovak",
  "sl": "Slovenian",
  "es": "Spanish",
  "sw": "Swahili",
  "sv": "Swedish",
  "ta": "Tamil",
  "te": "Telugu",
  "th": "Thai",
  "tr": "Turkish",
  "uk": "Ukrainian",
  "ur": "Urdu",
  "vi": "Vietnamese",
  "cy": "Welsh",
  "yi": "Yiddish"

module.exports = (robot) ->
  language_choices = (language for _, language of languages).sort().join('|')
  pattern = new RegExp('translate(?: me)?' +
                       "(?: from ([a-z]{2}))?" +
                       "(?: (?:in)?to ([a-z]{2}))?" +
                       '(.*)', 'i')
  robot.respond pattern, (msg) ->
    term = msg.match[3].trim()
    data = "q=#{term}"
    origin = if msg.match[1] isnt undefined then msg.match[1] else 'auto'
    target = if msg.match[2] isnt undefined then msg.match[2] else 'en'

    msg.http("https://translate.googleapis.com/translate_a/single")
      .query({
        client: 'gtx'
        sl: origin
        tl: target
        ie: 'UTF-8'
        oe: 'UTF-8'
        dt: 't'
      })
      .header('Accept', '*/*')
      .header('User-Agent', 'Mozilla/4.0')
      .header('Content-Type', 'application/x-www-form-urlencoded')
      .header('Connection', 'keep-alive')
      .header('Accept-Encoding', 'gzip, deflate')
      .post(data) (err, res, body) ->
        if err
          msg.send "Failed to connect to GAPI"
          robot.emit 'error', err, res
          return

        try
          if body.length > 4 and body[0] == '['
            parsed = JSON.parse(body)
            language = languages[parsed[2]]
            parsed = parsed[0]
            transed = ''
            transed += line[0] for line in parsed
            if parsed
              if msg.match[2] is undefined
                msg.send "#{term} is #{language} for #{transed}"
              else
                msg.send "The #{language} #{term} translates as #{transed} in #{languages[target]}"
          else
            throw new SyntaxError 'Invalid JS code'

        catch err
          msg.send "Failed to parse GAPI response"
          robot.emit 'error', err
