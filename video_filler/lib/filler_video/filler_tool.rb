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

  def FillerTool.findFillers(duration, minCandidate, maxCandidate, gapAllowed, duplicate)
    videos = FillerVideo.select("id, name, source, length").where("expired = 0 and length <= ?", duration)
    retVal, numCandidates = {}, 0

    filler = Fillers.new(videos, duplicate)
    retVal[0] = filler.find(duration, maxCandidate)
    numCandidates += retVal[0].size
    return retVal if numCandidates >= minCandidate

    1.upto(gapAllowed) do |n|
      retVal[n] = filler.find(duration + n, maxCandidate - retVal.size)
      numCandidates += retVal[n].size
      break if numCandidates >= minCandidate
      
      retVal[-n] = filler.find(duration - n, maxCandidate - retVal.size)
      numCandidates += retVal[-n].size
      break if numCandidates >= minCandidate
    end
    
    return retVal
  end
end
