require 'date'
require 'time'
require 'bigdecimal'
require 'bigdecimal/util'

module ClientBankExchange
  class << self
    def parse_file path
      parse File.read(path, encoding: 'windows-1251:utf-8')
    end
  
    def parse content
      result = {
        errors: [],
        general: {},
        remainings: {},
        filters: {},
        documents: []
      }
  
      if content.start_with? '1CClientBankExchange'
        result[:general] = general(content)
  
        result[:remainings] = remainings(content)
  
        result[:documents] = documents(content)
      else
        result[:errors] << 'Wrong format: 1CClientBankExchange not found'
      end
  
      result
    end
  
    private

    def general content
      result = {}

      # parse general info (key=value)
      [
        :ВерсияФормата, :Кодировка,
        :Отправитель, :Получатель,
        :ДатаСоздания, :ВремяСоздания
      ].each do |key|
        /#{key}=(.*)/.match(content) do |match|
          result[key] = match[1].strip
        end
      end

      hash_value_to_date result, :ДатаСоздания
      hash_value_to_time result, :ВремяСоздания

      result
    end

    def remainings content
      result = {}

      /СекцияРасчСчет([\s\S]*?)\sКонецРасчСчет/.match(content) do |match|
        # remainings properties (key=value)
        match[1].scan(/(.*)=(.*)/) { |k, v| result[k.to_sym] = v.strip }

        # normalize
        hash_value_to_date result, :ДатаНачала
        hash_value_to_date result, :ДатаКонца
        hash_value_to_d result, :НачальныйОстаток
        hash_value_to_d result, :ВсегоПоступило
        hash_value_to_d result, :ВсегоСписано
        hash_value_to_d result, :КонечныйОстаток
      end

      result
    end

    def documents content
      regexp_document = /СекцияДокумент=(.*)\s([\s\S]*?)\sКонецДокумента/
      content.scan(regexp_document).map do |doc|
        # document type
        document = { СекцияДокумент: doc[0] }

        # document properties (key=value)
        doc[1].scan(/(.*)=(.*)/) { |k, v| document[k.to_sym] = v.strip }

        # normalize
        hash_value_to_i document, :Номер
        hash_value_to_date document, :Дата
        hash_value_to_d document, :Сумма

        document
      end
    end  
  
    def hash_value_to_date hash, key
      hash[key] = Date.parse(hash[key]) if hash[key]
    end
  
    def hash_value_to_time hash, key
      hash[key] = Time.parse(hash[key]) if hash[key]
    end
  
    def hash_value_to_i hash, key
      hash[key] = hash[key].to_i if hash[key]
    end
  
    def hash_value_to_d hash, key
      hash[key] = hash[key].to_d if hash[key]
    end
  end
end
