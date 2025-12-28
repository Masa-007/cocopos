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
import ProgressSliderController from "./progress_slider_controller";
import MilestonesController from "./milestones_controller";
import PostTypeFieldsController from "./post_type_fields_controller";
import PostVisibilityController from "./post_visibility_controller";

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
application.register("progress-slider", ProgressSliderController);
application.register("milestones", MilestonesController);
application.register("post-type-fields", PostTypeFieldsController);
application.register("post-visibility", PostVisibilityController);

window.application = application;
