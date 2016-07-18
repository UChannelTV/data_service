module FillerTool
  class Fillers
    def initialize(videos, duplicate)
      @videos = videos
      @lens = []
      @numVideos = videos.size
      @shift = (duplicate) ? 1 : 0
    end

    def find(duration, maxCandidate)
      match, cache = [], [[[]]]
      1.upto(duration - 1) do |n|
        cache << []
      end

      while (true)
        cache, numCache = findMore(match, duration, maxCandidate, cache)
        break if numCache == 0
      end

      retVal = []
      match.each do |l|
        val = []
        l.each do |id|
          val << @videos[id]
        end
        retVal << val
      end
      retVal
    end

    def findMore(match, duration, maxCandidate, cache)
      newCache, numMatches, numCache = [], match.size, 0
      0.upto(duration - 1) do |n|
        newCache << []
      end

      0.upto(@numVideos - 1) do |index|
        len = @videos[index][:length]
        n = duration - len
        next if n < 0
        cache[n].each do |l| 
          next if l.size > 0 and l.last >= (index + @shift)
          v = l.dup
          v << index
          match << v
          numMatches += 1
          return [[], 0] if numMatches >= maxCandidate
        end

        0.upto(n-1) do |m|
          k = m + len
          cache[m].each do |l|
            break if newCache[k].size >= (numMatches + 1)
            next if l.size > 0 and l.last >= (index + @shift) 
            v = l.dup
            v << index
            newCache[k] << v
            numCache += 1
          end
        end
      end

      return [newCache, numCache]
    end
  end

  def self.findFillers(duration, min_candidate, max_candidate, allowed_gap, allow_duplicate)
    duration = duration.to_i
    return invalid_param('Total Duration') if duration <= 0

    minCandidate = (min_candidate.nil?) ? 1 : min_candidate.to_i
    return invalid_param('Mininum Candidates') if minCandidate <= 0

    maxCandidate = (max_candidate.nil?) ? minCandidate + 10 : max_candidate.to_i
    return invalid_param('Maximum Candidates') if minCandidate > maxCandidate

    gapAllowed = (allowed_gap.nil?) ? 3 : allowed_gap.to_i
    return invalid_param('Allowed Gap') if gapAllowed < 0
    
    duplicate = (allow_duplicate.nil?) ? false : (allow_duplicate.downcase.eql?("true"))

    videos = FillerVideo.select("id, name, source, length").where("expired = 0 and length <= ?", duration)
    retVal, numCandidates = {}, 0
    filler = Fillers.new(videos, duplicate)

    numCandidates += addCandidate(retVal, filler.find(duration, maxCandidate), 0)
    return [retVal, nil, 200] if numCandidates >= minCandidate

    1.upto(gapAllowed) do |n|
      numCandidates += addCandidate(retVal, filler.find(duration + n, maxCandidate - retVal.size), n)
      break if numCandidates >= minCandidate
      
      numCandidates += addCandidate(retVal, filler.find(duration - n, maxCandidate - retVal.size), -n)
      break if numCandidates >= minCandidate
    end
    
    return [retVal, nil, 200]
  end

  def self.findFillerData(duration, min_candidate, max_candidate, allowed_gap, allow_duplicate)
    fillerVideos, msg, code = findFillers(duration, min_candidate, max_candidate, allowed_gap, allow_duplicate)
    return [nil, nil, msg] if code != 200
    return [nil, nil, "No match found"] if fillerVideos.size == 0

    maxFillers = 1
    fillerVideos.values.each do |val|
      val.each do |videos|
        maxFillers = videos.size if videos.size > maxFillers
      end
    end
    
    fields = [3, ["Total Duration", "Gap", "Num of Videos"], []]
    1.upto(maxFillers).each do |n|
      fields[1] << "Video #{n}"
      fields[2] << "Name"
      fields[2] << "Source"
      fields[2] << "Duration"
    end

    videos = []
    fillerVideos.each do |key, val|
      shift = key.abs
      dur = durStr(duration.to_i + key)
      val.each do |vs|
        n = vs.size
        tv = [dur, shift, n]
        0.upto(n-1) do |m|
          tv << vs[m].name
          tv << vs[m].source
          tv << durStr(vs[m].length)
        end
        n.upto(maxFillers-1) do
          tv << "NA"
          tv << "NA"
          tv << "0:00"
        end
        videos << tv
      end
    end

    return [videos, fields, nil]
  end

  private

  def self.addCandidate(candidates, newCandidates, index)
    num = newCandidates.size
    candidates[index] = newCandidates if num > 0
    return num
  end

  def self.invalid_param(name)
    [nil, "Please set proper value for parameter '#{name}'", 400]
  end

  def self.durStr(dur)
    "%d:%02d" % [dur/60, dur%60]
  end
end
