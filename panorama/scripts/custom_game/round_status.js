(function () {
    var panel = $.GetContextPanel();
    var roundLabel = panel.FindChildTraverse("RoundLabel");
    var nextWaveLabel = panel.FindChildTraverse("NextWaveLabel");

    function updateRoundState() {
        var state = CustomNetTables.GetTableValue("round_system", "state");
        if (state) {
            roundLabel.text = "Round: " + (state.round || 0);
            nextWaveLabel.text = "Next wave in: " + (state.time_to_next || 0) + "s";
        }
        $.Schedule(0.2, updateRoundState);
    }

    updateRoundState();
})();
