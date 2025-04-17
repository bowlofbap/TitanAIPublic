local AudioFiles = require(game:GetService("ReplicatedStorage").Repos.AudioRepo)
local SoundService = game:GetService("SoundService")

local AudioHandler = {}
AudioHandler.__index = AudioHandler

function AudioHandler.new()
	local self = setmetatable({}, AudioHandler)
	self._soundCache = {}
	self._currentMusic = nil
	return self
end

function AudioHandler:PlaySound(audioData)
	local sound: Sound = self:_getSound(audioData)
	if not sound then 
		warn("Sound not found", audioData)
		return
	end
	sound:Play()
end

function AudioHandler:PlayMusic(audioData, fadeTime)
	fadeTime = fadeTime or 0
	if self._currentMusic then
		print("Change music")
		self:_fadeOut(self._currentMusic, fadeTime)
	end

	local music: Sound = self:_getSound(audioData)
	if not music then 
		warn("Sound not found", audioData)
		return
	end
	music.Looped = true
	music.Volume = 0
	music:Play()

	--self:_fadeIn(music, fadeTime, audioData)
	self._currentMusic = music
	print(self._currentMusic)
end

function AudioHandler:_preloadSounds(soundPaths)
	for _, path in ipairs(soundPaths) do
		self:_getSound(path)
	end
end

function AudioHandler:_fadeIn(sound, duration, audioData)
	for vol = 0, audioData.defaultVolume, 0.1 do
		sound.Volume = vol
		task.wait(duration/10)
	end
end

function AudioHandler:_fadeOut(sound, duration)
	if duration > 0 then
		for vol = 1, 0, -0.1 do
			sound.Volume = vol
			task.wait(duration/10)
		end
	end
	sound:Stop()
end

function AudioHandler:_getSound(audioData)
	local existingSound: Sound = self._soundCache[audioData.id]
	if existingSound and not existingSound.IsPlaying then
		return existingSound
	else
		local sound = Instance.new("Sound")
		sound.Parent = SoundService
		sound.SoundId = audioData.id
		sound.Volume = audioData.defaultVolume
		sound.PlaybackSpeed = audioData.defaultSpeed
		sound:Play()
		if existingSound and existingSound.IsPlaying then
			sound.Ended:Connect(function()
				sound:Destroy()
			end)
		else
			self._soundCache[audioData.id] = sound
		end
		return sound
	end
end

return AudioHandler
