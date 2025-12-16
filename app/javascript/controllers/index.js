// app/javascript/controllers/index.js
import { Application } from "@hotwired/stimulus";

import SeasonController from "./season_controller";
import CalendarTooltipController from "./calendar_tooltip_controller";
import ShareController from "./share_controller";
import SlideshowController from "./slideshow_controller";
import MoodController from "./mood_controller";
import MoodChartController from "./mood_chart_controller";
import MenuController from "./menu_controller";
import AiWriterController from "./ai_writer_controller";
import PostSubmitController from "./post_submit_controller";

const application = Application.start();

application.register("season", SeasonController);
application.register("calendar-tooltip", CalendarTooltipController);
application.register("share", ShareController);
application.register("slideshow", SlideshowController);
application.register("mood", MoodController);
application.register("mood-chart", MoodChartController);
application.register("menu", MenuController);
application.register("ai-writer", AiWriterController);
application.register("post-submit", PostSubmitController);

window.application = application;

