require 'mysql2'

client = Mysql2::Client.new(host: 'db09', username: 'loki', password: 'v4WmZip2K67J6Iq7NXC', database: 'applicant_tests')
results = client.query('select id, candidate_office_name from hle_dev_test_igor_sas;')

results.each do |result|
  result_clean = result['candidate_office_name'].gsub(/\\\\|,\\/, '/').gsub('.', '')
  result_clean_splits = result_clean.split('/')
  result_clean = ''

  result_clean_splits.each.with_index do |part, index|
    part = part.gsub('  ', ' ').strip
    if index == result_clean_splits.length - 1 && result_clean_splits.length > 1
      part = "#{part.strip} "
    elsif part.index(',')
      partpart = part.split(',')
      partpart.each.with_index do |part, index|
        if index.zero?
          part = " #{part.downcase!} "
        else
          part = " #{part.insert(1, '(').insert(-1, ')')} "
        end
      end
      part = partpart.join
    else
      part = part.downcase
    end

    if index == result_clean_splits.length - 1
      result_clean.insert(0, part)
    elsif index.zero?
      result_clean += " #{part} "
    else
      result_clean += " and #{part} "
    end
  end
  result_clean = result_clean.gsub('  ', ' ').strip
  result_clean = result_clean.gsub(/[Tt]wp/, 'Township').gsub(/[Tt]ownship [Tt]ownship/, 'Township')
  result_clean = result_clean.gsub(/[Hh]wy/, 'Highway').gsub(/[Hh]ighway [Hh]ighway/, 'Highway')
  result_clean = result_clean.gsub(/[Cc]ounty [Cc]ounty/, 'County')
  result_clean = result_clean.gsub('\'', '\\\\\'')

  result_sentence = "The candidate is running for the #{result_clean} office."

  client.query("Update hle_dev_test_igor_sas set clean_name = '#{result_clean}', sentence = '#{result_sentence}' where id = #{result['id']}")

end
client.close
