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
        # parse general info (key=value)
        [
          :ВерсияФормата, :Кодировка,
          :Отправитель, :Получатель,
          :ДатаСоздания, :ВремяСоздания
        ].each do |key|
          /#{key}=(.*)/.match(content) do |match|
            result[:general][key] = match[1].strip
          end
        end
  
        hash_value_to_date result[:general], :ДатаСоздания
        hash_value_to_time result[:general], :ВремяСоздания
  
        # parse remainings
        /СекцияРасчСчет([\s\S]*?)\sКонецРасчСчет/.match(content) do |match|
          # remainings properties (key=value)
          match[1].scan(/(.*)=(.*)/) { |k, v| result[:remainings][k.to_sym] = v.strip }
  
          # normalize
          hash_value_to_date result[:remainings], :ДатаНачала
          hash_value_to_date result[:remainings], :ДатаКонца
          hash_value_to_d result[:remainings], :НачальныйОстаток
          hash_value_to_d result[:remainings], :ВсегоПоступило
          hash_value_to_d result[:remainings], :ВсегоСписано
          hash_value_to_d result[:remainings], :КонечныйОстаток
        end
  
        # parse documents
        regexp_document = /СекцияДокумент=(.*)\s([\s\S]*?)\sКонецДокумента/
        result[:documents] = content.scan(regexp_document).map do |doc|
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
      else
        result[:errors] << 'Wrong format: 1CClientBankExchange not found'
      end
  
      result
    end
  
    private
  
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
