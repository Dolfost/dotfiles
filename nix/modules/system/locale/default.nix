{ ... }: {
	time.timeZone = "Europe/Kyiv";
	i18n.defaultLocale = "en_US.UTF-8";
	i18n.extraLocaleSettings = {
		LC_TIME = "en_GB.UTF-8";
		LC_MEASUREMENT = "uk_UA.UTF-8";
	};
}
