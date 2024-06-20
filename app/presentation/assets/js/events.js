function toRubyDateTime(date, time) {
    // 2024-03-14 09:00:00 +0800
    // date: collect from html date input
    // time: collect from html time input
    const timezone = new Date().toString().match(/([-\+][0-9]+)\s/)[1];
    return `${date} ${time}:00 ${timezone}`;
}

document.querySelector("#create-event-modal form").addEventListener("submit", function (ev) {
    ev.preventDefault();

    // construct start_time from start_date and start_hour
    const start_date = this.querySelector("#start_date").value;
    const start_hour = this.querySelector("#start_hour").value;
    const start_time = toRubyDateTime(start_date, start_hour);

    // construct end_time from end_date and end_hour
    const end_date = this.querySelector("#end_date").value;
    const end_hour = this.querySelector("#end_hour").value;
    const end_time = toRubyDateTime(end_date, end_hour);

    console.log(start_time);
    console.log(end_time);

    // place values into hidden inputs
    this.querySelector("#start_time").value = start_time;
    this.querySelector("#end_time").value = end_time;

    this.submit();
});