require 'yaml'

# ja.ymlを読み込む
config = YAML.load_file('config/locales/ja.yml')

# promptsキーの値を取得する
prompts = config.fetch('prompts')

# timeキーの値を取得する
time = config.fetch('time')

# hourキーの値を取得する
hour = time.fetch('hour')

# minuteキーの値を取得する
minute = time.fetch('minute')
